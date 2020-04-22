require "test_helper"

def create_presenter(range)
  @activities = range.map { |date| build(:activity, date: date) }
  @graph = Graph::Presenter.new(range, @activities)
end

module GraphPresenterTest
  class ColumnsTest < ActiveSupport::TestCase
    test "create one column for each month present in range" do
      create_presenter(Date.new(2020, 3, 29)..Date.new(2020, 4, 30))

      results = @graph.columns

      assert_equal 2, results.size

      first_column = results.first
      assert_equal 3, first_column.month
      assert_equal 2020, first_column.year

      second_column = results.second
      assert_equal 4, second_column.month
      assert_equal 2020, second_column.year
    end

    test "calculates column width using the month's weeks size minus one" do
      create_presenter(Date.new(2020, 3, 29)..Date.new(2020, 4, 30))

      results = @graph.columns

      assert_equal 0, results.first.width
      assert_equal 4, results.second.width
    end

    test "increases prior month width if the subsequent month starts first week in a sunday" do
      create_presenter(Date.new(2020, 7, 28)..Date.new(2020, 9, 30))

      results = @graph.columns

      assert_equal 0, results.first.width
      assert_equal 5, results.second.width
      assert_equal 4, results.third.width
    end
  end

  class SquaresTest < ActiveSupport::TestCase
    test "creates one square for each date present in range" do
      create_presenter(Date.new(2020, 3, 29)..Date.new(2020, 4, 4))

      results = @graph.squares

      assert_equal 7, results.size

      first_square = results.first
      first_activity = @activities.first

      assert_equal first_activity.date, first_square.date
      assert_equal first_activity.amount, first_square.amount

      last_square = results.last
      last_activity = @activities.last

      assert_equal last_activity.date, last_square.date
      assert_equal last_activity.amount, last_square.amount
    end

    test "sums activities amount per day" do
      @activities = [
        build_list(:activity, 4, amount: 6, date: Date.new(2020, 4, 1)),
        build_list(:activity, 6, amount: 7, date: Date.new(2020, 4, 2))
      ].flatten
      @graph = Graph::Presenter.new((Date.new(2020, 4, 1)..Date.new(2020, 4, 2)), @activities)

      results = @graph.squares

      assert_equal 2, results.size
      assert_equal 24, results.first.amount
      assert_equal 42, results.second.amount
    end
  end

  class CssGridTest < ActiveSupport::TestCase
    test "joins all css columns when call css_grid" do
      @graph = create_presenter((Date.new(2020, 3, 1)..Date.new(2020, 4, 19)))

      result = @graph.css_grid

      assert_equal "calc(var(--week-width) * 4) calc(var(--week-width) * 3)", result
    end
  end
end
