require "test_helper"

class User
  class CrawlDataTest < ActiveSupport::TestCase
    setup do
      @user = build(:user)
      @crawler_mock = Minitest::Mock.new
      @service = CrawlData.set(user: @user, crawler: @crawler_mock)
    end

    test "returns crawled data and its checksum" do
      crawled_data = {
        profile: {
          avatar_url: "http://dummy/avatar",
          location: "Jakarta"
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

      result = @service.call
      @crawler_mock.verify

      assert result.success?
      assert_equal crawled_data, result.crawled_data
      assert result.checksum.present?
    end

    test "returns error message wen crawl fails" do
      error_message = "Something went wrong"
      @crawler_mock.expect(:crawl, nil) do
        raise MAL::Errors::CrawlError, error_message
      end

      result = @service.call
      @crawler_mock.verify

      assert result.failure?
      assert_equal result.message, error_message
    end
  end
end
