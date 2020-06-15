require "test_helper"

class GraphComponentTest < ViewComponent::TestCase
  setup do
    @range = (Date.new(2019, 5, 5)..Date.new(2020, 5, 9))
  end

  test "renders squares correctly" do
    activities = [
      build(:activity, date: Date.new(2020, 1, 1), amount: 1),
      build(:activity, date: Date.new(2020, 1, 2), amount: 5),
      build(:activity, date: Date.new(2020, 1, 3), amount: 9),
      build(:activity, date: Date.new(2020, 1, 4), amount: 13)
    ]
    component = render_inline(GraphComponent.new(date_range: @range, activities: activities))

    squares = component.css(".graph > .squares > .square")

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
    component = render_inline(GraphComponent.new(date_range: @range, activities: []))

    component.css(".graph > .days > .day").then do |elements|
      assert_equal %w[Sun Mon Tue Wed Thu Fri Sat], elements.map(&:text)
    end
  end

  test "renders each months correctly" do
    range = (Date.new(2019, 5, 5)..Date.new(2020, 5, 9))
    component = render_inline(GraphComponent.new(date_range: range, activities: []))

    component.css(".graph > .months > .month").then do |elements|
      assert_equal %w[May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr May], elements.map(&:text)
    end
  end
end
