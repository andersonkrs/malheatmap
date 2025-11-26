require "test_helper"

class User::PeriodicMALSyncJobTest < ActiveJob::TestCase
  test "performs crawler pipeline when the user is eligible for sync" do
    fake_pipeline = mock(:pipeline)
    fake_pipeline.expects(:execute!).returns(nil)
    User.any_instance.stubs(:crawler_pipeline).returns(fake_pipeline)

    user = User.create!(username: "john-bass", mal_synced_at: 1.day.ago)

    User::PeriodicMALSyncJob.perform_now(user)
  end

  test "does not execute pipeline when the user is not eligible" do
    fake_pipeline = mock(:pipeline)
    fake_pipeline.expects(:execute!).never
    User.any_instance.stubs(:crawler_pipeline).returns(fake_pipeline)

    user = User.create!(username: "john-bass", mal_synced_at: 1.hour.ago)

    User::PeriodicMALSyncJob.perform_now(user)
  end

  test "enqueues user deactivation when the retries are exhausted and the user is a legacy account" do
    user = User.create!(username: "john-bass", mal_synced_at: nil, mal_id: nil, mal_synced_at: nil)
    error_message = "Profile not found for username %{username}. Please check if you typed it correctly."
    error = MAL::Errors::ProfileNotFound.new(error_message)

    fake_pipeline = mock(:fake_pipeline)
    fake_pipeline.stubs(:execute!).raises(error)
    User.any_instance.stubs(:crawler_pipeline).returns(fake_pipeline)

    User::PeriodicMALSyncJob.perform_later(user)

    freeze_time

    16.times do
      perform_enqueued_jobs only: User::PeriodicMALSyncJob
    end

    assert_enqueued_with(
      job: User::Deactivatable::DeactivationJob,
      args: [
        user.id,
        user.updated_at,
        error_message
      ],
      at: User::Deactivatable::DEACTIVATION_BUFFER.from_now.noon
    )
  end
end
