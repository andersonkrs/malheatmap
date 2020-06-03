require "test_helper"

module UserData
  class SaveTest < ActiveSupport::TestCase
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
      @user = create(:user)
      @service = Save.set(user: @user, crawled_data: @data)
    end

    test "generates new checksum" do
      assert_changes -> { @user.checksum } do
        result = @service.call

        assert result.success?
        assert result.data_updated
      end
    end

    test "updates profile data" do
      @service.call

      assert_equal "http://dummy/avatar", @user.avatar_url
      assert_equal 2, @user.entries.size
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

    test "does not update user's checksum when it does not have new entries" do
      @user.update!(checksum: "f00289e0aa45a692cc224e0308f6bd92")

      result = @service.call

      assert result.success?
      assert_not result.data_updated
      assert_no_changes -> { @user.checksum } do
        @user.reload
      end
    end

    test "inserts just the new entries when user already has entries with more than 3 weeks" do
      create(:entry, user: @user, timestamp: 22.days.ago.in_time_zone)

      assert_changes -> { @user.entries.count }, from: 1, to: 3 do
        @service.call
      end
    end
  end
end
