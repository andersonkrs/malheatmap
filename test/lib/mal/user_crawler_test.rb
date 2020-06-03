require "test_helper"

class UserCrawlerTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.local(2020, 3, 21, 12, 30)
  end

  test "returns user profile info" do
    crawler = MAL::UserCrawler.new("andersonkrs")
    result = crawler.crawl

    assert_equal(
      { avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1582993800" },
      result[:profile]
    )
  end

  test "returns all entries when user has history" do
    crawler = MAL::UserCrawler.new("andersonkrs")
    result = crawler.crawl

    assert_equal 5, result[:history].size
  end

  test "returns no entries when user does not have history" do
    crawler = MAL::UserCrawler.new("Ismail_Hassan")
    result = crawler.crawl

    assert_equal 0, result[:history].size
  end

  test "raises profile not found error when user does not exist" do
    crawler = MAL::UserCrawler.new("fakeuser123")

    assert_raises MAL::Errors::ProfileNotFound do
      crawler.crawl
    end
  end
end
