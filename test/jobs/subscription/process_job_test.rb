require "test_helper"

class Subscription
  class ProcessJobTest < ActiveSupport::TestCase
    setup do
      @subscription = Subscription.create!(username: "random")
    end

    test "calls subscription processed" do
      Subscription::ProcessJob.perform_now(@subscription)

      assert true, @subscription.processed?
    end
  end
end
