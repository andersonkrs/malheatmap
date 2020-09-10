require "test_helper"

class User
  class PersistCrawledDataTest < ActiveSupport::TestCase
    setup do
      @data = {
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
          },
          {
            timestamp: "2019-12-06T16:11:03",
            amount: 6,
            item_id: 5,
            item_name: "One Punch Man",
            item_kind: "anime"
          }
        ]
      }
      @checksum = SecureRandom.uuid
      @user = create(:user)
      @service = PersistCrawledData.set(user: @user, crawled_data: @data, checksum: @checksum)
    end

    test "updates profile data and checksum" do
      @service.call

      assert_equal "http://dummy/avatar", @user.avatar_url
      assert_equal 2, @user.entries.size
      assert_equal @checksum, @user.checksum
    end

    test "inserts all entries to user" do
      assert_changes -> { @user.entries.count }, from: 0, to: 2 do
        @service.call
      end

      entries = @user.entries.order(:timestamp)
      entry = entries.first
      assert_equal DateTime.new(2019, 12, 6, 15, 0, 0), entry.timestamp
      assert_equal 1, entry.amount
      assert_equal 121, entry.mal_id
      assert_equal "Death Note", entry.name
      assert_equal "manga", entry.kind

      entry = entries.last
      assert_equal DateTime.new(2019, 12, 6, 16, 11, 3), entry.timestamp
      assert_equal 6, entry.amount
      assert_equal 5, entry.mal_id
      assert_equal "One Punch Man", entry.name
      assert_equal "anime", entry.kind
    end

    test "inserts just the new entries when user already has entries with more than 3 weeks" do
      create(:entry, user: @user, timestamp: 22.days.ago.in_time_zone)

      assert_changes -> { @user.entries.count }, from: 1, to: 3 do
        @service.call
      end
    end
  end
end
