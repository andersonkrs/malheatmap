require "test_helper"

class User::DeactivatableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:babyoda)
  end

  test "user is active by default" do
    assert @user.active?
    assert_not @user.deactivated?
  end

  test "deactivate! marks user as deactivated" do
    freeze_time do
      @user.deactivate!
      assert @user.deactivated?
      assert_not @user.active?
      assert_equal Time.current, @user.deactivated_at
    end
  end

  test "schedule_deactivation enqueues DeactivationJob" do
    reason = "User requested"
    assert_enqueued_with(
      job: User::Deactivatable::DeactivationJob,
      args: [@user.id, @user.updated_at, reason]
    ) do
      @user.schedule_deactivation(reason: reason)
    end
  end
end
