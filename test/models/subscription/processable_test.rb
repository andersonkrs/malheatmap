require "test_helper"

class User
  class ProcessableTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers
    include Turbo::Streams::ActionHelper

    test "enqueues background job to process when submitted" do
      subscription = Subscription.create!(username: "test")

      assert_enqueued_jobs 1 do
        subscription.submitted
      end

      assert_equal false, subscription.processed?
      assert_enqueued_with job: Subscription::ProcessJob, args: [subscription]
    end

    test "does not enqueue anything when it's already been processed" do
      subscription = Subscription.create!(username: "test", processed_at: Time.current)

      assert_no_enqueued_jobs { subscription.submitted }
    end

    test "processing should broadcast status success with user url when crawler returns valid data" do
      MAL::UserCrawler
        .any_instance
        .stubs(:crawl)
        .returns(
          {
            profile: {
              avatar_url: "https://dummy/avatar",
              location: "Nowhere+",
              latitude: -34.92866,
              longitude: 138.59863,
              time_zone: "UTC"
            },
            history: []
          }
        )
      subscription = Subscription.create!(username: "random")

      broadcast_content =
        turbo_stream_action_tag(
          "redirect",
          :target => "body",
          :path => user_path(subscription.username),
          "turbo-action" => "replace"
        )
      assert_broadcast_on(subscription.to_gid_param, broadcast_content) { subscription.processed }
    end

    test "processing should save the outcome when the crawler executes without errors and crate the user record" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler
        .any_instance
        .stubs(:crawl)
        .returns(
          {
            profile: {
              avatar_url: "https://dummy/avatar",
              location: "Nowhere+",
              latitude: -34.92866,
              longitude: 138.59863,
              time_zone: "UTC"
            },
            history: []
          }
        )

      subscription.processed

      user = User.find_by(username: "random")
      assert user
      assert subscription.processed?
      assert_equal subscription.redirect_path, user_path(user)
      assert_equal subscription.process_errors, []
    end

    test "processing should broadcast the form with the errors returned by the crawler" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("error!"))

      form =
        render(partial: "subscriptions/form", locals: { subscription: Subscription.new(process_errors: ["error!"]) })
      broadcast_content = turbo_stream_action_tag("replace", target: dom_id(subscription), template: form)

      assert_broadcast_on(subscription.to_gid_param, broadcast_content) { subscription.processed }
    end

    test "processing should save the errors returned by the crawler and not create a user record" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("error!"))

      subscription.processed

      assert_not User.exists?(username: subscription.username)
      assert subscription.processed?
      assert_nil subscription.redirect_path
      assert_equal subscription.process_errors, ["error!"]
    end

    test "processing should broadcast internal server redirect when something unexpected happens" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(ArgumentError, "unexpected error!")

      broadcast_content =
        turbo_stream_action_tag(
          "redirect",
          :target => "body",
          :path => internal_error_path,
          "turbo-action" => "replace"
        )

      assert_broadcast_on(subscription.to_gid_param, broadcast_content) { subscription.processed }
    end

    test "processing should save the errors captured and not create a user record" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(ArgumentError, "unexpected error!")

      subscription.processed

      assert_not_equal 1
      assert_not User.exists?(username: subscription.username)
      assert subscription.processed?
      assert_equal subscription.redirect_path, internal_error_path
      assert_equal subscription.process_errors, ["unexpected error!"]
    end
  end
end
