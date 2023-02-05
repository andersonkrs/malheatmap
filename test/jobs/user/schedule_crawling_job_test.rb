require "test_helper"

class User
  class ScheduleCrawlingJobTest < ActiveJob::TestCase
    test "schedules the crawling jobs for each user" do
      ScheduleCrawlingJob.perform_now

      assert_enqueued_jobs User.count
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:john_doe)]
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:babyoda)]
      assert_enqueued_with job: User::CrawlDataJob, args: [users(:anderson)]
    end
  end
end
