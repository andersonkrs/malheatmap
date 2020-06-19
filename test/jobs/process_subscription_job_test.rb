require "test_helper"

class ProcessSubscriptionJobTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @subscription = create(:subscription)
  end

  test "calls service with given subscription" do
    service_mock = lambda do |params|
      assert_equal params, { subscription: @subscription }
    end

    ProcessSubscription.stub(:call, service_mock) do
      ProcessSubscriptionJob.perform_now(@subscription)
    end
  end
end
