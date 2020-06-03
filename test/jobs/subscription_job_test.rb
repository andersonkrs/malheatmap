require "test_helper"

class SubscriptionJobTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @subscription = create(:subscription)
    @stream_id = SubscriptionChannel.broadcasting_for(@subscription)
  end

  test "broadcasts status success with user url when update service returns success" do
    SyncronizationService.stub(:syncronize_user_data, status: :success) do
      SubscriptionJob.perform_now(@subscription)
    end

    assert @subscription.processed?
    assert_broadcast_on @stream_id, status: :success, user_url: user_path(@subscription.username)
  end

  test "broadcasts status error with error template when update service returns an error" do
    expected_template = ApplicationController.render(
      partial: "subscriptions/alert",
      locals: { message: "ops!" }
    )

    SyncronizationService.stub(:syncronize_user_data, status: :error, message: "ops!") do
      SubscriptionJob.perform_now(@subscription)
    end

    assert_broadcast_on @stream_id, status: :failure, template: expected_template
  end
end
