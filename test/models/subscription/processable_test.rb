require "test_helper"

class User
  class ProcessableTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers
    include CrawledDataTestHelper

    test "enqueues background job to process after create" do
      subcription = build(:subscription)

      assert_enqueued_jobs 1 do
        subcription.save!
      end

      assert_equal false, subcription.processed?
      assert_enqueued_with job: Subscription::ProcessJob, args: [subcription]
    end

    test "does not enqueue anything when updating" do
      subcription = create(:subscription)

      assert_no_enqueued_jobs do
        subcription.touch
      end
    end

    test "broadcasts status success with user url when update service returns success" do
      subscription = create(:subscription)
      MAL::UserCrawler.stub_response(subscription.username, valid_crawled_data)

      subscription.process!

      assert User.exists?(username: subscription.username)
      assert subscription.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :success, redirect: user_path(subscription.username))
    end

    test "broadcasts status error with error template when update service returns an error" do
      subscription = create(:subscription)
      MAL::UserCrawler.stub_response(subscription.username, MAL::Errors::CrawlError.new("error!"))

      subscription.process!

      assert_not User.exists?(username: subscription.username)
      assert subscription.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure,
                          notification: ApplicationController.render(NotificationComponent.new(message: "error!")))
    end

    test "broadcasts internal server error message when something unexpected happen" do
      subscription = create(:subscription)
      create(:user, username: subscription.username)

      subscription.process!

      assert subscription.processed?
      assert_broadcast_on(SubscriptionChannel.broadcasting_for(subscription),
                          status: :failure, redirect: internal_error_path)
    end
  end
end
