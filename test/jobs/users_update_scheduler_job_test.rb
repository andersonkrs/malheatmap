require "test_helper"

class UsersUpdateSchedulerJobTest < ActiveSupport::TestCase
  setup do
    create_list(:user, 6, updated_at: 5.hours.ago)
    create_list(:user, 3, updated_at: 13.hours.ago)
  end

  test "schedules update job for users which were updated 12 hours ago" do
    assert_enqueued_jobs 6, only: UserUpdateJob, queue: "low" do
      UsersUpdateSchedulerJob.perform_now
    end
  end
end
