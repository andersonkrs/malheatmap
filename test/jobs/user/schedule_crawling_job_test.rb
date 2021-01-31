require "test_helper"

class User
  class ScheduleCrawlingJobTest < ActiveJob::TestCase
    test "schedules update data job for each user which is qualified for updating based on the last update date" do
      users(:babyoda).update!(updated_at: 12.hours.ago)
      users(:john_doe).update!(updated_at: 13.hours.ago)
      users(:anderson).update!(updated_at: 1.hour.ago)

      ScheduleCrawlingJob.perform_now

      assert_enqueued_jobs 2
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:john_doe)]
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:babyoda)]

      travel_to 12.hours.from_now

      assert_enqueued_jobs 3 do
        ScheduleCrawlingJob.perform_now
      end
    end
  end
end
