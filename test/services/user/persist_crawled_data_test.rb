require "test_helper"

class User
  class PersistCrawledDataTest < ActiveSupport::TestCase
    setup do
      @data = {
        profile: {
          avatar_url: "http://dummy/avatar",
          location: "Adelaide, Australia",
          latitude: -34.92866,
          longitude: 138.59863,
          time_zone: "Australia/Adelaide"
        },
        history: [
          {
            timestamp: "1 hours ago",
            amount: 1,
            item_id: 121,
            item_name: "Death Note",
            item_kind: "manga"
          },
          {
            timestamp: "Yesterday, 3:17 AM",
            amount: 6,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          },
          {
            timestamp: "Oct 1, 7:55 PM",
            amount: 4,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          }
        ]
      }
      @checksum = SecureRandom.uuid
      @user = create(:user)

      @service = PersistCrawledData.set(user: @user, crawled_data: @data, checksum: @checksum)

      travel_to Time.zone.local(2020, 10, 3, 9, 0)
    end

    test "updates profile data and checksum" do
      @service.call

      assert_equal "http://dummy/avatar", @user.avatar_url
      assert_equal "Adelaide, Australia", @user.location
      assert_equal(-34.92866, @user.latitude)
      assert_equal 138.59863, @user.longitude
      assert_equal "Australia/Adelaide", @user.time_zone
      assert_equal 3, @user.entries.size
      assert_equal @checksum, @user.checksum
    end

    test "inserts all entries to user" do
      assert_changes -> { @user.entries.count }, from: 0, to: 3 do
        @service.call
      end

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

      entry = entries.last
      assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 1, 19, 55), entry.timestamp
      assert_equal 4, entry.amount
      assert_equal 5, entry.mal_id
      assert_equal "One Punch Man", entry.name
      assert_equal "anime", entry.kind
    end

    test "inserts just the new entries when user already has entries with more than 3 weeks" do
      create(:entry, user: @user, timestamp: 21.days.ago)

      assert_changes -> { @user.entries.count }, from: 1, to: 4 do
        @service.call
      end
    end
  end
end
