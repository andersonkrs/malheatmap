require "test_helper"

class TimelinePresenterTest < ActiveSupport::TestCase
  class ActivitiesByMonthAndDateTest < ActiveSupport::TestCase
    setup do
      @activities = [
        build(:activity, date: Date.new(2020, 4, 1)),
        build(:activity, date: Date.new(2020, 4, 1)),
        build(:activity, date: Date.new(2020, 4, 2)),
        build(:activity, date: Date.new(2020, 4, 3)),
        build(:activity, date: Date.new(2020, 5, 1)),
        build(:activity, date: Date.new(2020, 5, 2))
      ]
    end

    test "returns all activities grouped by month and date" do
      @presenter = TimelinePresenter.new(@activities)

      results = @presenter.activities_by_month_and_date

      april_activities = results[Date.new(2020, 4, 1)]
      may_activities = results[Date.new(2020, 5, 1)]

      assert_equal 3, april_activities.size
      assert_equal 2, may_activities.size

      assert_equal 2, april_activities[Date.new(2020, 4, 1)].size
      assert_equal 1, april_activities[Date.new(2020, 4, 2)].size
      assert_equal 1, april_activities[Date.new(2020, 4, 3)].size
      assert_equal 1, may_activities[Date.new(2020, 5, 1)].size
      assert_equal 1, may_activities[Date.new(2020, 5, 2)].size
    end
  end
end
