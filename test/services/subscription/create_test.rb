require "test_helper"

class Subscription
  class CreateTest < ActiveSupport::TestCase
    test "creates subscription record with given username and enqueue the process job" do
      result = Subscription::Create.call(username: "Jonas")

      assert result.success?
      assert_instance_of Subscription, result.subscription
      assert_not result.subscription.processed
      assert_enqueued_with job: Subscription::ProcessJob, args: [result.subscription]
    end
  end
end
