require "test_helper"

class UserCrawlerTest < ActiveSupport::TestCase
  include VCRCassettes

  test "returns user profile info with geolocation and history" do
    crawler = MAL::UserCrawler.new("andersonkrs")
    result = crawler.crawl

    assert_equal(
      {
        location: "Sorocaba, Brazil",
        avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1601605800"
      },
      result[:profile]
    )

    assert_equal 10, result[:history].size

    entry = result[:history].first
    assert_equal "Sep 21, 7:33 PM", entry[:timestamp]
    assert_equal 39_597, entry[:item_id]
    assert_equal "Sword Art Online: Alicization - War of Underworld", entry[:item_name]
    assert_equal 9, entry[:amount]
  end

  test "returns no entries when user does not have history" do
    crawler = MAL::UserCrawler.new("Ismail_Hassan")
    result = crawler.crawl

    assert_equal 0, result[:history].size
  end

  test "returns no entries when user sets the history as private" do
    crawler = MAL::UserCrawler.new("-Kazami")
    result = crawler.crawl

    assert_equal 0, result[:history].size
  end

  test "raises profile not found error when user does not exist" do
    crawler = MAL::UserCrawler.new("fakeuser123")

    assert_raises MAL::Errors::ProfileNotFound, I18n.t("mal.crawler.errors.profile_not_found") do
      crawler.crawl
    end
  end

  test "raises communication error when some connection error occur" do
    crawler = MAL::UserCrawler.new("someuser")

    stub_request(:any, /#{MAL::HOST}/).to_return(status: 303)

    assert_raises MAL::Errors::CommunicationError, I18n.t("mal.crawler.errors.communication_error") do
      crawler.crawl
    end
  end

  test "raises communication error when MAL returns any 5xx error" do
    crawler = MAL::UserCrawler.new("someuser")

    stub_request(:any, /#{MAL::HOST}/).to_return(status: 503)

    assert_raises MAL::Errors::CommunicationError do
      crawler.crawl
    end
  end
end
