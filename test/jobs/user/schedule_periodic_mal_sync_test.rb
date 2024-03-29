require "test_helper"

class User::SchedulePeriodicMALSyncTest < ActiveJob::TestCase
  test "schedules if the user never had synced" do
    user = User.create!(username: "Robson", mal_synced_at: nil)

    User::SchedulePeriodicMALSyncJob.perform_now

    assert_enqueued_with job: User::PeriodicMALSyncJob, args: [user]
  end

  test "schedules if the user had synced more than 12 hours ago" do
    user = User.create!(username: "Robson", mal_synced_at: 13.hours.ago)

    User::SchedulePeriodicMALSyncJob.perform_now

    assert_enqueued_with job: User::PeriodicMALSyncJob, args: [user]
  end

  test "does not schedule for users that had synced less than the minimum interval" do
    User.delete_all

    _user_a = User.create!(username: "Paul", mal_synced_at: 2.hours.ago)
    user_b = User.create!(username: "Robson", mal_synced_at: 15.hours.ago)

    User::SchedulePeriodicMALSyncJob.perform_now

    assert_enqueued_jobs 1, only: User::PeriodicMALSyncJob
    assert_enqueued_with job: User::PeriodicMALSyncJob, args: [user_b]
  end
end
