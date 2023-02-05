require "test_helper"

class User
  class CalendarsTest < ActiveSupport::TestCase
    setup do
      travel_to Time.zone.local(2020, 4, 19)

      @user = users(:babyoda)
      @user.created_at = Time.zone.local(2017, 10, 1)
    end

    test "returns last year range if given year is the current year" do
      result = @user.calendars[2020].dates

      assert_equal (Date.new(2019, 4, 14)..Date.new(2020, 4, 19)), result
    end

    test "returns first sunday and the last day of the year if it is not the current year" do
      result = @user.calendars[2019].dates

      assert_equal (Date.new(2018, 12, 30)..Date.new(2019, 12, 31)), result
    end

    test "returns first day of the year if it starts on a sunday" do
      result = @user.calendars[2017].dates

      assert_equal (Date.new(2017, 1, 1)..Date.new(2017, 12, 31)), result
    end

    test "returns the years range since the user has subscribed or had recorded the first activity" do
      travel_to Date.new(2021, 1, 1)
      user = User.create!(username: "random1")
      assert_equal (2021..2021), user.calendars.active_years
      assert_equal 1, user.calendars.size
      assert_equal 2021, user.calendars.first.year

      travel_to Date.new(2017, 10, 15)
      user = User.create!(username: "random2")

      travel_to Date.new(2021, 1, 1)
      assert_equal 5, user.calendars.size
      assert_equal 2017, user.calendars.first.year
      assert_equal 2018, user.calendars.second.year
      assert_equal 2019, user.calendars.third.year
      assert_equal 2020, user.calendars.fourth.year
      assert_equal 2021, user.calendars.fifth.year

      user.activities.create!(item: items(:naruto), amount: 1, date: Date.new(2016, 12, 30))
      user.reload
      assert_equal (2016..2021), user.calendars.active_years
    end
  end
end
