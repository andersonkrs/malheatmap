require "test_helper"

class TimelineComponentTest < ViewComponent::TestCase
  test "renders each timeline marker correctly" do
    activities = [
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 10, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 7, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 4, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 3, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 2, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2020, 1, 1))
    ]

    component = render_inline(TimelineComponent.new(activities: activities))

    assert_equal "October", component.css(".header-marker").text
    assert_equal "January", component.css(".footer-marker").text
    assert_equal %w[July April March February January], component.css(".separator-marker").map(&:text)
  end

  test "renders grouped activities per day" do
    activities = [
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2019, 6, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2019, 6, 1)),
      Activity.new(item: items(:one_piece), amount: 1, date: Date.new(2019, 5, 1))
    ]

    component = render_inline(TimelineComponent.new(activities: activities))

    assert_equal 2, component.css("[data-date='2019-06-01']").css("p.activity").size
    assert_equal 1, component.css("[data-date='2019-05-01']").css("p.activity").size
  end
end
