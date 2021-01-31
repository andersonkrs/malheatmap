require "test_helper"

class User
  class ProcessableTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers

    test "enqueues background job to process after create" do
      subcription = Subscription.new(username: "test")

      assert_enqueued_jobs 1 do
        subcription.save!
      end

      assert_equal false, subcription.processed?
      assert_enqueued_with job: Subscription::ProcessJob, args: [subcription]
    end

    test "does not enqueue anything when updating" do
      subcription = Subscription.create!(username: "test")

      assert_no_enqueued_jobs do
        subcription.touch
      end
    end

    test "processing should broadcast status success with user url when crawler returns valid data" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.stub_response(subscription.username, valid_crawled_data)

      subscription.process!

      assert User.exists?(username: subscription.username)
      assert subscription.reload.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :success, redirect: user_path(subscription.username))
    end

    test "processing should broadcast status error with error template when crawler returns an error" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.stub_response(subscription.username, MAL::Errors::CrawlError.new("error!"))

      subscription.process!

      assert_not User.exists?(username: subscription.username)
      assert subscription.reload.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure,
                          notification: ApplicationController.render(NotificationComponent.new(message: "error!"),
                                                                     layout: false))
    end

    test "processing should broadcast internal server error message when something unexpected happen" do
      subscription = Subscription.create!(username: "random")
      MAL::UserCrawler.stub_response(subscription.username, StandardError.new("unexpected error!"))

      subscription.process!

      assert subscription.reload.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure, redirect: internal_error_path)
    end

    private

    def valid_crawled_data
      JSON.parse(file_fixture("user_crawled_data.json").read, symbolize_names: true)
    end
  end
end
