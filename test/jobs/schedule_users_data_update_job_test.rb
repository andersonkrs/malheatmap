require "test_helper"

class ScheduleUsersDataUpdateJobTest < ActiveJob::TestCase
  setup do
    @users = create_list(:user, 3)
  end

  test "schedule update data job for each user on db" do
    ScheduleUsersDataUpdateJob.perform_now

    assert_enqueued_jobs 3
    assert_enqueued_with job: User::UpdateDataJob, args: [@users.first]
    assert_enqueued_with job: User::UpdateDataJob, args: [@users.second]
    assert_enqueued_with job: User::UpdateDataJob, args: [@users.third]
  end
end
