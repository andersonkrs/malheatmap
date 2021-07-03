require "test_helper"

class User
  class CrawlableTest < ActiveSupport::TestCase
    setup do
      @user = users(:babyoda)
      @crawler_response = {
        profile: {
          avatar_url: "https://dummy/avatar",
          location: "Adelaide, Australia",
          latitude: -34.92866,
          longitude: 138.59863,
          time_zone: "Australia/Adelaide"
        },
        history: [
          {
            timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 3, 17, 30),
            amount: 1,
            item_id: 121,
            item_name: "Death Note",
            item_kind: "manga"
          },
          {
            timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 2, 3, 17),
            amount: 6,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          },
          {
            timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 1, 19, 55),
            amount: 4,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          },
          {
            timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 1, 19, 30),
            amount: 3,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          }
        ]
      }

      MAL::UserCrawler.any_instance.stubs(:crawl).returns(@crawler_response)
    end

    test "updates user profile data and inserts all entries to user parsing the natural timestamps correctly" do
      result = @user.crawl_data

      assert_equal true, result
      assert @user.checksum.present?
      assert_equal "https://dummy/avatar", @user.avatar_url
      assert_equal "Adelaide, Australia", @user.location
      assert_equal(-34.92866, @user.latitude)
      assert_equal 138.59863, @user.longitude
      assert_equal "Australia/Adelaide", @user.time_zone

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

      assert_equal 1, @user.crawling_log_entries.count
      crawling_log_entry = @user.crawling_log_entries.first
      assert_equal crawling_log_entry.checksum, @user.checksum
      assert_equal false, crawling_log_entry.failure?
      assert_nil crawling_log_entry.failure_message
      assert_equal @crawler_response, crawling_log_entry.raw_data.deep_symbolize_keys
      assert_enqueued_with job: Purgeable::PurgeRecordJob, args: [crawling_log_entry]

      assert_equal 3, @user.activities.count
      assert_equal true, @user.signature.attached?
    end

    test "updates item name if it has changed" do
      entry_data = @crawler_response[:history].first
      item = Item.create!(mal_id: entry_data[:item_id], kind: entry_data[:item_kind], name: "Old Name")

      @user.crawl_data

      assert_changes -> { item.name }, from: "Old Name", to: entry_data[:item_name] do
        item.reload
      end
    end

    test "does not delete user entries if just the profile changed" do
      @user.entries.create!(timestamp: 5.days.ago, item: items(:boruto), amount: 10)
      @crawler_response[:history] = []

      assert_no_changes -> { @user.entries.count } do
        @user.crawl_data
      end
    end

    test "does not destroy entries older that the oldest present on the crawled data payload" do
      travel_to Time.zone.local(2020, 10, 3, 20, 0, 0)

      entry_to_be_destroyed = { timestamp: Time.zone.local(2020, 10, 1, 20, 0, 0), item: items(:one_punch_man),
                                amount: 1 }
      entry_not_to_be_destroyed = { timestamp: Time.zone.local(2020, 9, 30), item: items(:one_punch_man), amount: 2 }
      @user.entries.create!([entry_not_to_be_destroyed, entry_to_be_destroyed])

      @user.crawl_data

      assert_not @user.entries.exists?(entry_to_be_destroyed)
      assert @user.entries.exists?(entry_not_to_be_destroyed)
    end

    test "raises an error if the oldest crawled entry is older than 30 days" do
      @user.entries.create!([timestamp: Time.zone.now, item: items(:one_punch_man), amount: 2])
      @crawler_response[:history].first[:timestamp] = 30.days.ago.in_time_zone

      assert_raises Crawlable::CrawlingLogEntry::DeletingOldHistoryNotAllowed do
        @user.crawl_data
      end

      assert_equal 1, @user.entries.count
    end

    test "saves the navigation history" do
      MAL::UserCrawler.any_instance.stubs(:history).returns(
        [
          stub(body: "<html>profile</html>", uri: URI.parse("https://dummy/myuser/profile")),
          stub(body: "<html>history</html>", uri: URI.parse("https://dummy/myuser/history"))
        ]
      )
      @user.crawl_data

      visited_pages = @user.crawling_log_entries.first.visited_pages.order(:created_at)

      assert_equal 2, visited_pages.size
      assert_equal "profile.html", visited_pages.first.filename.sanitized
      assert_equal "history.html", visited_pages.second.filename.sanitized
    end

    test "does not update user's data when checksum did not change" do
      travel_to Date.new(2020, 10, 3)

      @user.crawl_data

      assert_no_changes -> { @user.attributes.except("updated_at") } do
        @user.crawl_data
      end

      assert_no_changes -> { @user.entries.count } do
        @user.crawl_data
      end

      assert_no_changes -> { @user.activities.count } do
        @user.crawl_data
      end

      assert_no_changes -> { @user.signature.blob.created_at } do
        @user.crawl_data
      end
    end

    test "updates signature if the checksum dit not change but the last signature date changed" do
      travel_to Date.new(2020, 10, 3)

      @user.crawl_data

      travel_to Time.find_zone(@user.time_zone).tomorrow

      assert_changes -> { @user.reload.signature.blob.created_at } do
        @user.crawl_data
      end
    end

    test "returns false when a crawling error occurs " do
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("Something went wrong"))

      result = @user.crawl_data

      assert_equal false, result
      assert_equal ["Something went wrong"], @user.errors[:base]
    end

    test "creates a log entry with the failure message and an error occurs during the crawling" do
      MAL::UserCrawler.any_instance.stubs(:history).returns([
                                                              stub(body: "<html>something wrong here</html>",
                                                                   uri: URI.parse("https://dummy/myuser/profile"))
                                                            ])
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("Something wrong here"))

      @user.crawl_data

      assert_equal 1, @user.crawling_log_entries.size
      log_entry = @user.crawling_log_entries.first
      assert_equal true, log_entry.failure?
      assert_equal "Something wrong here", log_entry.failure_message

      visited_pages = log_entry.visited_pages.order(:created_at)

      assert_equal 1, visited_pages.size
      assert_equal "profile.html", visited_pages.first.filename.sanitized
    end
  end
end
