require "test_helper"

class User
  class ProcessableTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers

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

      assert_no_enqueued_jobs do
        subscription.submitted
      end
    end

    test "processing should broadcast status success with user url when crawler returns valid data" do
      MAL::UserCrawler.any_instance.stubs(:crawl).returns({
                                                            profile: {
                                                              avatar_url: "https://dummy/avatar",
                                                              location: "Nowhere+",
                                                              latitude: -34.92866,
                                                              longitude: 138.59863,
                                                              time_zone: "UTC"
                                                            },
                                                            history: []
                                                          })

      subscription = Subscription.create!(username: "random")
      subscription.processed

      assert User.exists?(username: subscription.username)
      assert subscription.processed?

      skip
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :success, redirect: user_path(subscription.username))
    end

    test "processing should broadcast status error with error template when crawler returns an error" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("error!"))

      subscription.processed

      assert_not User.exists?(username: subscription.username)
      assert subscription.processed?

      skip
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure,
                          notification: ApplicationController.render(NotificationComponent.new(message: "error!"),
                                                                     layout: false))
    end

    test "processing should broadcast internal server error message when something unexpected happen" do
      skip

      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(ArgumentError, "unexpected error!")

      subscription.processed

      assert_not User.exists?(username: subscription.username)
      assert subscription.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure, redirect: internal_error_path)
    end
  end
end
