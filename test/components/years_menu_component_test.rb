require "test_helper"

class YearsMenuComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @user = users(:babyoda)
  end

  test "renders each year with correctly user link" do
    component = render_inline(YearsMenuComponent.new(user: @user, years: [2019, 2018, 2020], active_year: 2019))

    links = component.css("a")
    assert_equal 3, links.size

    assert_equal "2020", links[0].text
    assert_includes user_path(@user, year: 2020), links[0].attr("href")

    assert_equal "2019", links[1].text
    assert_includes user_path(@user, year: 2019), links[1].attr("href")

    assert_equal "2018", links[2].text
    assert_includes user_path(@user, year: 2018), links[2].attr("href")
  end

  test "sets active year with given selected year" do
    component = render_inline(YearsMenuComponent.new(user: @user, years: [2020, 2019], active_year: 2020))
    assert_equal "2020", component.css("a.is-active").text

    component = render_inline(YearsMenuComponent.new(user: @user, years: [2020, 2019], active_year: 2019))
    assert_equal "2019", component.css("a.is-active").text
  end
end
