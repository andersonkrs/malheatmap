require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:entries).dependent(:delete_all).inverse_of(:user)
    should have_many(:activities).dependent(:delete_all).inverse_of(:user)
  end

  context "validations" do
    should_not validate_presence_of(:avatar_url)
    should_not validate_presence_of(:checksum)
    should validate_presence_of(:time_zone)
    should_not validate_presence_of(:latitude)
    should_not validate_presence_of(:longitude)

    should validate_numericality_of(:latitude).allow_nil
    should validate_numericality_of(:longitude).allow_nil
  end

  test "returns the years range since the user subscribed or had recorded the first activity" do
    travel_to Date.new(2021, 1, 1)
    user = User.create!(username: "random1")
    assert_equal (2021..2021), user.active_years

    travel_to Date.new(2017, 10, 15)
    user = User.create!(username: "random2")
    travel_to Date.new(2021, 1, 1)
    assert_equal (2017..2021), user.active_years

    user.activities.create!(item: items(:naruto), amount: 1, date: Date.new(2016, 12, 30))
    user.touch
    assert_equal (2016..2021), user.active_years
  end

  class ActivitiesScopesTest
    class ForDateRangeTest < ActiveSupport::TestCase
      setup do
        @user = users(:babyoda)
        @user.activities.create!(amount: 1, date: Date.new(2020, 6, 11), item: items(:naruto))
        @user.activities.create!(amount: 1, date: Date.new(2020, 7, 11), item: items(:one_piece))
        @user.activities.create!(amount: 1, date: Date.new(2020, 7, 11), item: items(:dragon_ball_gt))
        @user.activities.create!(amount: 1, date: Date.new(2020, 8, 11), item: items(:cowboy_bebop))
        @user.activities.create!(amount: 1, date: Date.new(2020, 9, 11), item: items(:bleach))
      end

      test "returns activities for the given date range" do
        results = @user.activities.for_date_range(Date.new(2020, 7, 11)..Date.new(2020, 8, 11)).map(&:name)

        assert_equal 3, results.size
        assert_includes results, "Cowboy Bebop"
        assert_includes results, "Dragon Ball GT"
        assert_includes results, "One Piece"
      end
    end

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
end
