require "test_helper"

class CreateSubscriptionTest < ActiveSupport::TestCase
  test "creates subscription record with given username and enqueue  the process job" do
    result = CreateSubscription.call(username: "Jonas")

    assert result.success?
    assert_instance_of Subscription, result.subscription
    assert_not result.subscription.processed
    assert_enqueued_with job: ProcessSubscriptionJob, args: [result.subscription]
  end
end
