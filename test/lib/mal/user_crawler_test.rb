require "test_helper"

class UserCrawlerTest < ActiveSupport::TestCase
  include VCRCassettes

  setup { travel_to Date.new(2020, 9, 22) } # Entries timestamps are relative to current date, need to freeze

  test "returns user profile info with geolocation and history" do
    Geocoder::Lookup::Test.add_stub("Sorocaba, Brazil", [{ coordinates: [-23.4961296, -47.4542266] }])
    crawler = MAL::UserCrawler.new("andersonkrs")

    result = crawler.crawl

    assert_equal(
      {
        location: "Sorocaba, Brazil",
        avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1601605800",
        latitude: -23.4961296,
        longitude: -47.4542266,
        time_zone: "America/Sao_Paulo"
      },
      result[:profile]
    )

    assert_equal 10, result[:history].size

    entry = result[:history].first
    assert_equal Time.find_zone("America/Sao_Paulo").local(2020, 9, 21, 19, 33).utc, entry[:timestamp]
    assert_equal 39_597, entry[:item_id]
    assert_equal "anime", entry[:item_kind]
    assert_equal "Sword Art Online: Alicization - War of Underworld", entry[:item_name]
    assert_equal 9, entry[:amount]
  end

  test "does not return user geolocation if the user does not have location on the profile" do
    crawler = MAL::UserCrawler.new("ft_suhail")
    result = crawler.crawl
    profile = result[:profile]

    assert profile[:location].blank?
    assert profile[:time_zone].blank?
    assert profile[:latitude].blank?
    assert profile[:longitude].blank?
  end

  test "returns UTC as timezone when the geolocation is not a country" do
    Geocoder::Lookup::Test.add_stub("Caspian Sea", [{ coordinates: [41.7789772, 50.5607579] }])

    crawler = MAL::UserCrawler.new("Moruna")
    result = crawler.crawl
    profile = result[:profile]

    assert_equal "UTC", profile[:time_zone]
  end

  test "does not return the timezone if the geolocation returns empty coordinates" do
    Geocoder::Lookup::Test.add_stub("Sorocaba, Brazil", [{ coordinates: [] }])

    crawler = MAL::UserCrawler.new("hacker_4chan")
    result = crawler.crawl
    profile = result[:profile]

    assert profile[:time_zone].blank?
    assert profile[:latitude].blank?
    assert profile[:longitude].blank?
  end

  test "removes blank spaces from item name and timestamp" do
    crawler = MAL::UserCrawler.new("ft_suhail")
    result = crawler.crawl
    profile = result[:profile]

    assert_equal "", profile[:location]
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
