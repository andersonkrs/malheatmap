require "test_helper"

class User
  class ScheduleCrawlingJobTest < ActiveJob::TestCase
    test "schedules the crawling jobs for each user with intervals between each batch" do
      ScheduleCrawlingJob.perform_now(batch_size: 1)

      assert_enqueued_jobs User.count
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:john_doe)]
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:babyoda)]
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:anderson)]

      assert_enqueued_with job: User::CrawlDataJob, at: 15.minutes.from_now
      assert_enqueued_with job: User::CrawlDataJob, at: 30.minutes.from_now
      assert_enqueued_with job: User::CrawlDataJob, at: 45.minutes.from_now
    end
  end
end
