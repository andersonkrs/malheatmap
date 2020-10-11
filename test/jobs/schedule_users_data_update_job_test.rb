require "test_helper"

class ScheduleUsersDataUpdateJobTest < ActiveJob::TestCase
  test "schedules update data job for each user which is qualified for updating based on the last update date" do
    qualified_users = create_list(:user, 3, updated_at: 12.hours.ago)
    create_list(:user, 4, updated_at: 3.hours.ago)
    create_list(:user, 2, updated_at: 2.hours.ago)

    ScheduleUsersDataUpdateJob.perform_now

    assert_enqueued_jobs 3
    assert_enqueued_with job: User::UpdateDataJob, args: [qualified_users.first]
    assert_enqueued_with job: User::UpdateDataJob, args: [qualified_users.second]
    assert_enqueued_with job: User::UpdateDataJob, args: [qualified_users.third]

    travel_to 12.hours.from_now

    assert_enqueued_jobs 9 do
      ScheduleUsersDataUpdateJob.perform_now
    end
  end
end
