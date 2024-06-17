require "test_helper"

class UserCrawlerTest < ActiveSupport::TestCase
  setup { travel_to Date.new(2020, 9, 22) } # Entries timestamps are relative to current date, need to freeze

  teardown do
    Geocoder::Lookup::Test.reset

    VCR.eject_cassette
  end

  test "returns user profile info with geolocation and history" do
    VCR.insert_cassette("user_crawler/user_with_complete_information")

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
    assert_equal Time.find_zone("America/Sao_Paulo").local(2020, 9, 21, 23, 33).utc, entry[:timestamp]
    assert_equal 39_597, entry[:item_id]
    assert_equal "anime", entry[:item_kind]
    assert_equal "Sword Art Online: Alicization - War of Underworld", entry[:item_name]
    assert_equal 9, entry[:amount]
  end

  test "converts history timestamps correctly to UTC" do
    VCR.insert_cassette "user_crawler/user_with_many_entries"
    travel_to Time.zone.local(2021, 6, 18, 23)

    Geocoder::Lookup::Test.add_stub("College/Massachusetts", [{ coordinates: [42.3788774, -72.032366] }])
    crawler = MAL::UserCrawler.new("Squashbucklr")

    result = crawler.crawl
    dates = result[:history].filter { |entry| entry[:item_id] == 40_870 }.pluck(:timestamp).sort.reverse

    Time.use_zone("America/New_York") do
      assert_equal dates.map(&:in_time_zone),
                   [
                     Time.zone.local(2021, 6, 15, 3, 23),
                     Time.zone.local(2021, 6, 15, 2, 58),
                     Time.zone.local(2021, 6, 15, 2, 28),
                     Time.zone.local(2021, 6, 15, 2, 4),
                     Time.zone.local(2021, 6, 15, 1, 40),
                     Time.zone.local(2021, 6, 15, 1, 13),
                     Time.zone.local(2021, 6, 14, 21, 52),
                     Time.zone.local(2021, 6, 14, 21, 28),
                     Time.zone.local(2021, 6, 14, 20, 59),
                     Time.zone.local(2021, 6, 14, 20, 34),
                     Time.zone.local(2021, 6, 14, 20, 5)
                   ]
    end
  end

  test "does not return user geolocation if the user does not have location on the profile" do
    VCR.insert_cassette "user_crawler/user_with_no_location"

    crawler = MAL::UserCrawler.new("ft_suhail")
    result = crawler.crawl
    profile = result[:profile]

    assert profile[:location].blank?
    assert profile[:time_zone].blank?
    assert profile[:latitude].blank?
    assert profile[:longitude].blank?
  end

  test "returns UTC as timezone when the geolocation is not a country" do
    VCR.insert_cassette "user_crawler/user_with_non_valid_country_location"

    Geocoder::Lookup::Test.add_stub("Caspian Sea", [{ coordinates: [41.7789772, 50.5607579] }])

    crawler = MAL::UserCrawler.new("Moruna")
    result = crawler.crawl
    profile = result[:profile]

    assert_equal "UTC", profile[:time_zone]
  end

  test "does not return the timezone if the geolocation returns empty coordinates" do
    VCR.insert_cassette("user_crawler/user_with_complete_information")
    Geocoder::Lookup::Test.add_stub("Sorocaba, Brazil", [{ coordinates: [] }])

    crawler = MAL::UserCrawler.new("andersonkrs")
    result = crawler.crawl
    profile = result[:profile]

    assert profile[:time_zone].blank?
    assert profile[:latitude].blank?
    assert profile[:longitude].blank?
  end

  test "returns no entries when user does not have history" do
    VCR.insert_cassette("user_crawler/no_history")

    crawler = MAL::UserCrawler.new("ft_suhail")
    result = crawler.crawl

    assert_equal 0, result[:history].size
  end

  test "raises profile not found error when user does not exist" do
    VCR.insert_cassette("user_crawler/profile_not_found")

    crawler = MAL::UserCrawler.new("fakeuser12312312")

    assert_raises MAL::Errors::ProfileNotFound, I18n.t("mal.crawler.errors.profile_not_found") do
      crawler.crawl
    end
  end

  test "raises communication error when some connection error occur" do
    crawler = MAL::UserCrawler.new("someuser")

    stub_request(:any, /#{MAL::HOST}/o).to_return(status: 303)

    assert_raises MAL::Errors::CommunicationError, match: /A communication error with myanimelist\.net has occurred/ do
      crawler.crawl
    end
  end

  test "raises communication error when MAL returns any 5xx error" do
    crawler = MAL::UserCrawler.new("someuser")

    stub_request(:any, /#{MAL::HOST}/o).to_return(status: 503)

    assert_raises MAL::Errors::CommunicationError, match: /Code\: 503/ do
      crawler.crawl
    end
  end
end
