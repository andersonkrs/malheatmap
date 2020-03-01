require "test_helper"

class SubscriptionJobTest < ActiveSupport::TestCase
  setup do
    @subscription = create(:subscription, status: :pending)
    @stream_id = SubscriptionChannel.broadcasting_for(@subscription)
  end

  test "updates subscription status to success when update service returns success" do
    UpdateService.stub(:call, status: :success) do
      SubscriptionJob.perform_now(@subscription)
    end

    assert @subscription.success?
    assert @subscription.reason.blank?
  end

  test "broadcasts status success with user url when update service returns success" do
    UpdateService.stub(:call, status: :success) do
      SubscriptionJob.perform_now(@subscription)
    end

    assert_broadcast_on @stream_id, status: :success, user_url: "/users/#{@subscription.username}"
  end

  test "updates subscription status to error when update service returns error" do
    error_message = "Somenting went wrong"

    UpdateService.stub(:call, status: :error, message: error_message) do
      SubscriptionJob.perform_now(@subscription)
    end

    assert @subscription.error?
    assert_equal error_message, @subscription.reason
  end

  test "broadcasts status error with error template when update service returns an error" do
    template_error = "<error>ops!</error>"

    UpdateService.stub(:call, status: :error, message: "ops!") do
      ApplicationController.stub(:render, template_error) do
        SubscriptionJob.perform_now(@subscription)
      end
    end

    assert_broadcast_on @stream_id, status: :error, template: template_error
  end
end
