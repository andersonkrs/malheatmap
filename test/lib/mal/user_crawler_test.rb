require "test_helper"

class UserCrawlerTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.local(2020, 3, 21, 12, 30)
  end

  test "returns user profile info" do
    result = MAL::UserCrawler.crawl("andersonkrs")

    assert_equal(
      { avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1582993800" },
      result[:profile]
    )
  end

  test "returns all entries when user has history" do
    result = MAL::UserCrawler.crawl("andersonkrs")

    assert_equal 5, result[:history].size
  end

  test "returns no entries when user does not have history" do
    result = MAL::UserCrawler.crawl("Ismail_Hassan")

    assert_equal 0, result[:history].size
  end

  test "raises profile not found error when user does not exist" do
    assert_raises MAL::Errors::ProfileNotFound do
      MAL::UserCrawler.crawl("fakeuser123")
    end
  end
end
