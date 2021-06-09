require "test_helper"

class User
  class CrawlDataJobTest < ActiveJob::TestCase
    setup do
      @user = users(:babyoda)
    end

    test "executes user crawling" do
      mock = Minitest::Mock.new(@user)
      mock.expect(:crawl_data, true)

      User::CrawlDataJob.perform_now(mock)

      mock.verify
    end
  end
end
