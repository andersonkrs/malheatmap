require "test_helper"

class CrawlUserDataTest < ActiveSupport::TestCase
  setup do
    @user = build(:user)
    @crawler_mock = Minitest::Mock.new
    @service = CrawlUserData.set(crawler: @crawler_mock)
  end

  test "returns crawled data" do
    crawled_data = {
      profile: {
        avatar_url: "http://dummy/avatar"
      },
      history: [
        {
          timestamp: "2019-12-06T15:00:00",
          amount: 1,
          item_id: 121,
          item_name: "Death Note",
          item_kind: "manga"
        }
      ]
    }
    @crawler_mock.expect(:crawl, crawled_data)

    result = @service.call(user: @user)
    @crawler_mock.verify

    assert result.success?
    assert crawled_data, result.crawled_data
  end

  test "returns error message wen crawl fails" do
    error_message = "Something went wrong"
    @crawler_mock.expect(:crawl, nil) do
      raise MAL::Errors::CrawlError, error_message
    end

    result = @service.call(user: @user)
    @crawler_mock.verify

    assert result.failure?
    assert result.message, error_message
  end
end
