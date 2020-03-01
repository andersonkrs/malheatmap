require "test_helper"

class CrawlerServiceTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.local(2019, 10, 14, 12, 30)
  end

  test "returns user profile info" do
    result = CrawlerService.call("andersonkrs")

    assert_equal :success, result[:status]
    assert_equal(
      { avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg?t=1582993800" },
      result[:profile]
    )
  end

  test "returns all entries when user has history" do
    result = CrawlerService.call("andersonkrs")

    assert_equal :success, result[:status]
    assert_equal 3, result[:entries].size
  end

  test "returns no entries when user does not have history" do
    result = CrawlerService.call("ImperfectBlue")

    assert_equal :success, result[:status]
    assert_equal 0, result[:entries].size
  end

  test "returns profile not found error when user does not exist" do
    result = CrawlerService.call("fakeuser123")

    assert_equal :error, result[:status]

    message = "Profile not found for username fakeuser123. Please check if you typed it correctly."
    assert_equal message, result[:message]
  end
end
