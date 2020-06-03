require "test_helper"

module UserQueries
  class ActivitiesForDateRangeTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
      create(:activity, user: @user, date: Date.new(2020, 6, 11), item: create(:item, name: "Naruto"))
      create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "One Piece"))
      create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "Dragon Ball GT"))
      create(:activity, user: @user, date: Date.new(2020, 8, 11), item: create(:item, name: "Cowboy Bebop"))
      create(:activity, user: @user, date: Date.new(2020, 9, 11), item: create(:item, name: "Bleach"))
      create(:activity, date: Date.new(2020, 7, 11))
    end

    test "returns activities for the given range ordered by date desc and name asc" do
      results = ActivitiesForDateRange.execute(user: @user, range: (Date.new(2020, 7, 11)..Date.new(2020, 8, 11)))

      assert 3, results.size
      assert_equal results.first.date, Date.new(2020, 8, 11)
      assert_equal results.first.name, "Cowboy Bebop"
      assert_equal results.second.date, Date.new(2020, 7, 11)
      assert_equal results.second.name, "Dragon Ball GT"
      assert_equal results.third.date, Date.new(2020, 7, 11)
      assert_equal results.third.name, "One Piece"
    end
  end
end
