require "test_helper"

module User
  class CrawlDataJobTest < ActiveJob::TestCase
  setup { @user = users(:babyoda) }

  test "executes user crawling without errors" do
    MAL::UserCrawler
      .any_instance
      .stubs(:crawl)
      .returns(
        {
          profile: {
            avatar_url: "https://dummy/avatar",
            location: "Sao Paulo, Brazil",
            latitude: -34.92866,
            longitude: 138.59863,
            time_zone: "America/Sao_Paulo"
          },
          history: []
        }
      )

    assert_changes -> { @user.checksum } do
      User::CrawlDataJob.perform_now(@user)
    end
  end

  test "logs the error message when the crawling fails" do
    MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("Something went wrong"))
    Rails.logger.expects(:warn).with(regexp_matches(/Something went wrong/)).once

    User::CrawlDataJob.perform_now(@user)
  end
  end
end
