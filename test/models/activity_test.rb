require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  class OrderedAsTimelineTest < ActiveSupport::TestCase
    setup do
      @user = users(:babyoda)
      @user.activities.create!(amount: 1, date: Date.new(2020, 7, 11), item: items(:one_piece))
      @user.activities.create!(amount: 1, date: Date.new(2020, 7, 11), item: items(:dragon_ball_gt))
      @user.activities.create!(amount: 1, date: Date.new(2020, 8, 11), item: items(:cowboy_bebop))
    end

    test "returns records ordered by date desc and name asc" do
      results = @user.activities.ordered_as_timeline.to_a

      assert_equal results.first.date, Date.new(2020, 8, 11)
      assert_equal results.first.name, "Cowboy Bebop"
      assert_equal results.second.date, Date.new(2020, 7, 11)
      assert_equal results.second.name, "Dragon Ball GT"
      assert_equal results.third.date, Date.new(2020, 7, 11)
      assert_equal results.third.name, "One Piece"
    end
  end
end
