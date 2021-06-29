require "test_helper"

class User
  class ActivitiesTest < ActiveSupport::TestCase
    setup do
      @user = users(:babyoda)
    end

    def activities
      @user.activities.order(:date)
    end

    test "creates activities with current position if there's just one entry" do
      @user.entries.create!(item: items(:naruto), timestamp: Date.new(2020, 1, 1), amount: 10)

      assert_changes -> { activities.count }, from: 0, to: 1 do
        assert_equal true, @user.activities.generate_from_history
      end

      activity = activities.first
      assert_equal 10, activity.amount
      assert_equal Date.new(2020, 1, 1), activity.date
    end

    test "keeps activity's amount unmodified if there are duplicated entries same date and item" do
      @user.entries.create!([
                              { item: items(:naruto), timestamp: Date.new(2020, 1, 1), amount: 10 },
                              { item: items(:naruto), timestamp: Date.new(2020, 1, 1), amount: 10 }
                            ])

      assert_changes -> { activities.count }, from: 0, to: 1 do
        @user.activities.generate_from_history
      end

      assert_equal 10, activities.first.amount
    end

    test "creates subsequent activities with the difference between positions" do
      @user.entries.create!([
                              { item: items(:naruto), timestamp: Date.new(2020, 1, 1), amount: 10 },
                              { item: items(:naruto), timestamp: Date.new(2020, 1, 2), amount: 15 }
                            ])

      assert_changes -> { activities.count }, from: 0, to: 2 do
        @user.activities.generate_from_history
      end

      assert_equal 10, activities.first.amount
      assert_equal 5, activities.second.amount
    end

    test "creates two activities when there are entries of different items on date" do
      @user.entries.create!([
                              { item: items(:cowboy_bebop), timestamp: Time.zone.local(2020, 1, 1, 12, 15),
                                amount: 10 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 1, 13, 30), amount: 20 }
                            ])

      assert_changes -> { activities.count }, from: 0, to: 2 do
        @user.activities.generate_from_history
      end

      first_activity = activities.first
      assert_equal 10, first_activity.amount

      second_activity = activities.second
      assert_equal 20, second_activity.amount

      assert_equal first_activity.date, second_activity.date
    end

    test "creates negative activity when user fall back the current position" do
      @user.entries.create!([
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 1), amount: 10 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 2), amount: 5 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 2), amount: 6 }
                            ])

      @user.activities.generate_from_history

      assert_equal 10, activities.first.amount
      assert_equal(-4, activities.second.amount)
    end

    test "creates just one activity per day when there are multiple entries of same item on date" do
      @user.entries.create!([
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 1), amount: 10 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 1), amount: 12 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 2), amount: 15 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 7), amount: 21 },
                              { item: items(:naruto), timestamp: Time.zone.local(2020, 1, 7), amount: 26 }
                            ])

      assert_changes -> { activities.count }, from: 0, to: 3 do
        @user.activities.generate_from_history
      end

      activity = activities.first
      assert_equal 12, activity.amount
      assert_equal Date.new(2020, 1, 1), activity.date

      activity = activities.second
      assert_equal 3, activity.amount
      assert_equal Date.new(2020, 1, 2), activity.date

      activity = activities.third
      assert_equal 11, activity.amount
      assert_equal Date.new(2020, 1, 7), activity.date
    end

    test "should keep the entry with the greater amount when they have the same timestamp" do
      @user.entries.create!(
        [
          { item: items(:naruto), timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 25 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 10 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 3 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 2 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 1 }
        ]
      )

      @user.activities.generate_from_history

      assert_equal 1, activities.size
      assert_equal 25, activities.first.amount
    end

    test "deletes all activities if the user does not have entries anymore" do
      @user.activities.create!(item: items(:naruto), date: Time.zone.today, amount: 10)

      @user.activities.generate_from_history

      assert_equal 0, activities.count
    end

    test "generates activities based on user time zone" do
      @user.time_zone = "Australia/Adelaide"
      @user.entries.build(item: items(:naruto),
                          timestamp: Time.find_zone(@user.time_zone).local(2020, 4, 10, 5),
                          amount: 1)
      @user.save!

      @user.activities.generate_from_history

      assert_equal Date.new(2020, 4, 10), activities.first.date
    end

    test "accumulates just the amount of new epsiodes/chapters after the first entry" do
      @user.entries.create!(
        [
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 8 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 8 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 9 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 9 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 10 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 10 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 11 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 11 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 12 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 12 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 13 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 23, 28), amount: 13 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 14 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 14 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 15 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 15 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 16 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 16 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 5, 21, 29), amount: 17 }
        ]
      )

      @user.activities.generate_from_history

      assert_equal 13, activities.first.amount
      assert_equal 3, activities.second.amount
      assert_equal 1, activities.third.amount
    end

    test "sums the entry count by day when the user calculates each entry as an activity despite the amount recorded" do
      @user.count_each_entry_as_an_activity = true
      @user.entries.build(
        [
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 8 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 2, 14, 33), amount: 9 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 14 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 3, 23, 25), amount: 14 },
          { item: items(:naruto), timestamp: Time.zone.local(2020, 10, 5, 21, 29), amount: 5 }
        ]
      )
      @user.save!

      @user.activities.generate_from_history

      assert_equal 3, activities.size

      assert_equal 2, activities.first.amount
      assert_equal 2, activities.second.amount
      assert_equal 1, activities.third.amount
    end
  end
end
