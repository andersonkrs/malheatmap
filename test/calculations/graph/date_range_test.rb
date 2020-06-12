require "test_helper"

module Graph
  class DateRangeTest < ActiveSupport::TestCase
    setup do
      travel_to Time.zone.local(2020, 4, 19)
    end

    test "returns last year range if given year is the current year" do
      result = Graph::DateRange.calculate_for(year: 2020)

      assert_equal (Date.new(2019, 4, 14)..Date.new(2020, 4, 19)), result
    end

    test "returns first sunday and the last day of the year if it is not the current year" do
      result = Graph::DateRange.calculate_for(year: 2019)

      assert_equal (Date.new(2018, 12, 30)..Date.new(2019, 12, 31)), result
    end

    test "returns first day of the year if it starts in a sunday" do
      result = Graph::DateRange.calculate_for(year: 2017)

      assert_equal (Date.new(2017, 1, 1)..Date.new(2017, 12, 31)), result
    end
  end
end
