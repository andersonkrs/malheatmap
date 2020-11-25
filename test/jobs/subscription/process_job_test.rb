require "test_helper"

class Subscription
  class ProcessJobTest < ActiveSupport::TestCase
    setup do
      @subscription = create(:subscription)
    end

    test "calls subscription process!" do
      mock = Minitest::Mock.new(@subscription)
      mock.expect(:process!, nil)

      Subscription::ProcessJob.perform_now(mock)

      mock.verify
    end
  end
end
