require "test_helper"

class Subscription
  class ProcessTest < ActiveSupport::TestCase
    include Rails.application.routes.url_helpers

    setup do
      @subscription = create(:subscription)
      @stream_id = SubscriptionChannel.broadcasting_for(@subscription)

      @service = Subscription::Process.set(subscription: @subscription)
    end

    test "broadcasts status success with user url when update service returns success" do
      result_mock = Minitest::Mock.new
      result_mock.expect(:success?, true)

      User::UpdateData.stub(:call, result_mock) do
        @service.call

        assert User.exists?(username: @subscription.username)
        assert @subscription.processed?
        assert_broadcast_on @stream_id, status: :success, redirect: user_path(@subscription.username)
      end
    end

    test "resets users count cache when subscribes successfully" do
      create_list(:user, 2)

      result_mock = Minitest::Mock.new
      result_mock.expect(:success?, true)

      User::UpdateData.stub(:call, result_mock) do
        assert_changes -> { User.cached_count }, from: 2, to: 3 do
          @service.call
        end
      end
    end

    test "broadcasts status error with error template when update service returns an error" do
      result_mock = Minitest::Mock.new
      result_mock.expect(:success?, false)
      result_mock.expect(:message, "something went wrong!")

      User::UpdateData.stub(:call, result_mock) do
        @service.call

        assert_not User.exists?(username: @subscription.username)
        assert @subscription.processed?

        expected_template = ApplicationController.render(NotificationComponent.new(message: "something went wrong!"))
        assert_broadcast_on @stream_id, status: :failure, notification: expected_template
      end
    end

    test "broadcasts internal server error message when something unexpected happen" do
      User::UpdateData.stub(:call, -> { raise StandardError, "something went wrong" }) do
        @service.call

        assert_not User.exists?(username: @subscription.username)
        assert @subscription.processed?
        assert_broadcast_on @stream_id, status: :failure, redirect: internal_error_path
      end
    end
  end
end
