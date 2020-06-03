require "test_helper"

module UserQueries
  class EntriesFromLastThreeWeeksTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
    end

    test "returns entries from the last three weeks" do
      create(:entry)
      create(:entry, user: @user, timestamp: 22.days.ago)
      entry1 = create(:entry, user: @user, timestamp: 2.days.ago)
      entry2 = create(:entry, user: @user, timestamp: 5.days.ago)

      results = EntriesFromLastThreeWeeks.execute(user: @user).pluck(:id)
      assert_equal results.sort, [entry1.id, entry2.id].sort
    end
  end
end
