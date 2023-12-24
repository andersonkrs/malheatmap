require "test_helper"

class User::ScheduleCrawlingJobTest < ActiveJob::TestCase
  test "schedules the crawling jobs for each active user" do
    User.create!(username: "Robson", deactivated_at: Time.current)

    User::ScheduleCrawlingJob.perform_now

    assert_enqueued_jobs 3
    assert_enqueued_with job: User::CrawlDataJob, args: [users(:john_doe)]
    assert_enqueued_with job: User::CrawlDataJob, args: [users(:babyoda)]
    assert_enqueued_with job: User::CrawlDataJob, args: [users(:anderson)]
  end
end
