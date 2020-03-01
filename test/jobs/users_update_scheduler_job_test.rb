require "test_helper"

class UsersUpdateSchedulerJobTest < ActiveSupport::TestCase
  setup do
    create_list(:user, 6)
  end

  test "schedules update job for each user" do
    assert_enqueued_jobs 6, only: UserUpdateJob, queue: "low" do
      UsersUpdateSchedulerJob.perform_now
    end
  end
end
