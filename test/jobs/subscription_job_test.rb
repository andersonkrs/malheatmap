require "test_helper"

class SubscriptionJobTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @subscription = create(:subscription)
    @stream_id = SubscriptionChannel.broadcasting_for(@subscription)
    @result_mock = Minitest::Mock.new
  end

  test "broadcasts status success with user url when update service returns success" do
    user = create(:user)
    @result_mock.expect(:success?, true)
    @result_mock.expect(:user, user)

    SubscribeUser.stub(:call, @result_mock) do
      SubscriptionJob.perform_now(@subscription)
    end

    assert @subscription.processed?
    assert_broadcast_on @stream_id, status: :success, user_url: user_path(user)
  end

  test "broadcasts status error with error template when update service returns an error" do
    @result_mock.expect(:success?, false)
    @result_mock.expect(:message, "something went wrong!")

    SubscribeUser.stub(:call, @result_mock) do
      SubscriptionJob.perform_now(@subscription)
    end

    expected_template = ApplicationController.render(
      partial: "subscriptions/alert",
      locals: { message: "something went wrong!" }
    )
    assert_broadcast_on @stream_id, status: :failure, template: expected_template
  end
end
