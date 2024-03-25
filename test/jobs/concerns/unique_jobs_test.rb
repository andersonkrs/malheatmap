require "test_helper"

class UniqueJobsTest < ActiveJob::TestCase
  class Bucket < ApplicationRecord
  end

  class BucketJob < ApplicationJob
    uniqueness_control key: ->(record) { [record.id, record.updated_at&.to_fs(:number)] },
                       expires_in: 30.minutes

    def perform(record)
      Rails.logger.debug(record)
    end
  end

  setup do
    ActiveRecord::Base.connection.create_table(:buckets) do |t|
      t.timestamps
    end
  end

  test "cancels duplicated jobs with matching keys" do
    record_a = Bucket.create(id: 1)
    record_b = Bucket.create(id: 2)

    BucketJob.perform_later(record_a)
    BucketJob.perform_later(record_b)

    assert_enqueued_with job: BucketJob, args: [record_a]
    assert_enqueued_with job: BucketJob, args: [record_b]

    clear_enqueued_jobs

    BucketJob.perform_later(record_a)
    BucketJob.perform_later(record_b)

    assert_no_enqueued_jobs
  end

  test "allows enqueuing when the key partially changes" do
    record_a = Bucket.create(id: 1)
    BucketJob.perform_later(record_a)

    clear_enqueued_jobs
    BucketJob.perform_later(record_a)

    assert_no_enqueued_jobs

    record_a.update!(updated_at: 2.minutes.from_now)
    BucketJob.perform_later(record_a)

    assert_enqueued_jobs 1, only: [BucketJob]
  end

  test "allows enqueuing when the lock expired" do
    record_a = Bucket.create(id: 1)
    BucketJob.perform_later(record_a)

    clear_enqueued_jobs
    BucketJob.perform_later(record_a)

    assert_no_enqueued_jobs

    travel_to 2.hours.from_now

    BucketJob.perform_later(record_a)

    assert_enqueued_jobs 1, only: [BucketJob]
  end

  test "multiple attempts should not extend the lock expiration" do
    record_a = Bucket.create(id: 1)
    BucketJob.perform_later(record_a)
    clear_enqueued_jobs

    travel_to 10.minutes.from_now
    BucketJob.perform_later(record_a)

    travel_to 10.minutes.from_now
    BucketJob.perform_later(record_a)

    assert_no_enqueued_jobs

    travel_to 15.minutes.from_now
    BucketJob.perform_later(record_a)

    assert_enqueued_jobs 1, only: [BucketJob]
  end
end
