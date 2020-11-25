require "test_helper"

class User
  class CrawlableTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)

      stub_crawler
    end

    def stub_crawler
      @response = JSON.parse(file_fixture("user_crawled_data.json").read, symbolize_names: true)

      MAL::UserCrawler.stub_response(@user.username, @response)
    end

    test "updates user profile data and inserts all entries to user parsing the natural timestamps correctly" do
      travel_to Time.zone.local(2020, 10, 3, 9, 0)

      result = @user.crawl_mal_data

      assert_equal true, result
      assert @user.checksum.present?
      assert_equal "http://dummy/avatar", @user.avatar_url
      assert_equal "Adelaide, Australia", @user.location
      assert_equal(-34.92866, @user.latitude)
      assert_equal 138.59863, @user.longitude
      assert_equal "Australia/Adelaide", @user.time_zone

      assert @user.signature.attached?

      assert_equal 4, @user.entries.count
      entries = @user.entries.order(timestamp: :desc)
      entry = entries.first
      assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 3, 17, 30), entry.timestamp
      assert_equal 1, entry.amount
      assert_equal 121, entry.mal_id
      assert_equal "Death Note", entry.name
      assert_equal "manga", entry.kind

      entry = entries.second
      assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 2, 3, 17), entry.timestamp
      assert_equal 6, entry.amount
      assert_equal 5, entry.mal_id
      assert_equal "One Punch Man", entry.name
      assert_equal "anime", entry.kind

      entry = entries.third
      assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 1, 19, 55), entry.timestamp
      assert_equal 4, entry.amount
      assert_equal 5, entry.mal_id
      assert_equal "One Punch Man", entry.name
      assert_equal "anime", entry.kind

      entry = entries.last
      assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 1, 19, 30), entry.timestamp
      assert_equal 3, entry.amount
      assert_equal 5, entry.mal_id
      assert_equal "One Punch Man", entry.name
      assert_equal "anime", entry.kind

      assert_equal 3, @user.activities.count
    end

    test "updates item name if its been updated" do
      entry_data = @response[:history].first
      item = create(:item, mal_id: entry_data[:item_id], kind: entry_data[:item_kind], name: "Old Name")

      @user.crawl_mal_data

      assert_changes -> { item.name }, from: "Old Name", to: entry_data[:item_name] do
        item.reload
      end
    end

    test "does not delete user entries if just the profile changed" do
      @response[:history] = []
      create(:entry, user: @user, timestamp: 5.days.ago)

      assert_no_changes -> { @user.entries.count } do
        @user.crawl_mal_data
      end
    end

    test "does not update user's data when checksum did not change" do
      @user.crawl_mal_data

      stub_crawler
      assert_no_changes -> { @user.attributes.except("updated_at") } do
        @user.crawl_mal_data
      end

      stub_crawler
      assert_no_changes -> { @user.entries.count } do
        @user.crawl_mal_data
      end

      stub_crawler
      assert_no_changes -> { @user.activities.count } do
        @user.crawl_mal_data
      end

      stub_crawler
      assert_no_changes -> { @user.signature.blob.created_at } do
        @user.crawl_mal_data
      end
    end

    test "updates signature if the checksum dit not change but the last signature date changed" do
      @user.crawl_mal_data

      travel_to Time.find_zone(@user.time_zone).tomorrow
      stub_crawler

      assert_changes -> { @user.signature.blob.created_at } do
        @user.crawl_mal_data
      end
    end

    test "returns false when a crawling error occurs" do
      MAL::UserCrawler.remove_stubs
      MAL::UserCrawler.stub_response(@user.username, MAL::Errors::CrawlError.new("Something went wrong"))

      result = @user.crawl_mal_data

      assert_equal false, result
      assert_equal ["Something went wrong"], @user.errors[:base]
    end
  end
end
