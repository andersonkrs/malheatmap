require "test_helper"

class Subscription
  class ProcessJobTest < ActiveSupport::TestCase
    setup { @subscription = Subscription.create!(username: "random") }

    test "calls subscription processed" do
      Subscription::ProcessJob.perform_now(@subscription)

      assert true, @subscription.processed?
    end
  end
end
