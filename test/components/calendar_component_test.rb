require "test_helper"

class CalendarComponentTest < ViewComponent::TestCase
  def group_activities(dates:, activities: {})
    dates.index_with do |date|
      activities.fetch(date, 0)
    end
  end

  test "renders squares correctly" do
    activities = group_activities(
      dates: Date.new(2019, 5, 5)..Date.new(2020, 5, 9),
      activities: {
        Date.new(2020, 1, 1) => 1,
        Date.new(2020, 1, 2) => 5,
        Date.new(2020, 1, 3) => 9,
        Date.new(2020, 1, 4) => 13
      }
    )

    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    squares = component.css(".calendar > .squares > .square")

    assert_equal 371, squares.size
    assert_equal "2019-05-05", squares.first.attr("data-date")
    assert_equal "2020-05-09", squares.last.attr("data-date")

    assert_equal 367, squares.css("[data-level='0']").size

    squares.css("[data-level='1']").then do |elements|
      assert_equal 1, elements.size
      assert_equal "#2020-01-01", elements.first.css("a").attr("href").value
      assert_equal "One activity on January 01, 2020", elements.first.attr("title")
    end

    squares.css("[data-level='2']").then do |elements|
      assert_equal 1, elements.size
      assert_equal "#2020-01-02", elements.first.css("a").attr("href").value
      assert_equal "5 activities on January 02, 2020", elements.first.attr("title")
    end

    squares.css("[data-level='3']").then do |elements|
      assert_equal 1, elements.size
      assert_equal "#2020-01-03", elements.first.css("a").attr("href").value
      assert_equal "9 activities on January 03, 2020", elements.first.attr("title")
    end

    squares.css("[data-level='4']").then do |elements|
      assert_equal 1, elements.size
      assert_equal "#2020-01-04", elements.first.css("a").attr("href").value
      assert_equal "13 activities on January 04, 2020", elements.first.attr("title")
    end
  end

  test "renders days names correctly" do
    activities = group_activities(dates: Date.new(2019, 5, 5)..Date.new(2020, 5, 9))
    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    component.css(".calendar > .days > .day").then do |elements|
      assert_equal %w[Sun Mon Tue Wed Thu Fri Sat], elements.map(&:text)
    end
  end

  test "renders each month correctly" do
    activities = group_activities(dates: Date.new(2019, 5, 5)..Date.new(2020, 5, 9))
    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    component.css(".calendar > .months > .month").then do |elements|
      assert_equal %w[May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr May], elements.map(&:text)
    end
  end

  test "does not show month's label if it has just one week" do
    activities = group_activities(dates: Date.new(2019, 5, 26)..Date.new(2020, 5, 26))
    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    component.css(".calendar > .months > .month").then do |elements|
      assert_equal %w[Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr May], elements.map(&:text).reject(&:blank?)
    end

    activities = group_activities(dates: Date.new(2019, 4, 28)..Date.new(2020, 4, 29))
    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    component.css(".calendar > .months > .month").then do |elements|
      assert_equal %w[May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr], elements.map(&:text).reject(&:blank?)
    end
  end

  test "calculate months css grid correctly" do
    activities = group_activities(dates: Date.new(2019, 6, 16)..Date.new(2020, 6, 19))
    component = render_inline(CalendarComponent.new(activities_amount_per_day: activities))

    component.css(".calendar > .months").attribute("style").then do |attribute|
      expected_grid = [
        "calc(var(--week-width) * 2) /* Jun */",
        "calc(var(--week-width) * 4) /* Jul */",
        "calc(var(--week-width) * 5) /* Aug */",
        "calc(var(--week-width) * 4) /* Sep */",
        "calc(var(--week-width) * 4) /* Oct */",
        "calc(var(--week-width) * 5) /* Nov */",
        "calc(var(--week-width) * 4) /* Dec */",
        "calc(var(--week-width) * 4) /* Jan */",
        "calc(var(--week-width) * 5) /* Feb */",
        "calc(var(--week-width) * 4) /* Mar */",
        "calc(var(--week-width) * 4) /* Apr */",
        "calc(var(--week-width) * 5) /* May */",
        "calc(var(--week-width) * 3) /* Jun */"
      ].join(" ")

      assert_includes attribute.value, expected_grid
    end
  end

  test "sum of months widths must match with the total of weeks" do
    range = (Date.new(2017, 12, 31)..Date.new(2018, 12, 31))

    loop do
      component = render_inline(CalendarComponent.new(activities_amount_per_day: group_activities(dates: range)))
      widths = component.css(".calendar > .months > .month/@data-width").map(&:value).map(&:to_i)
      weeks_size = (range.count / 7.0).ceil

      assert_equal weeks_size, widths.sum

      range = (range.first + 7..range.last + 7)
      break if range.last >= Date.new(2021, 12, 31)
    end
  end
end
