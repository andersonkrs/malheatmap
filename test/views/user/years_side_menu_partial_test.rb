require "test_helper"

class User::YearsSideMenuPartialTest < ActionView::TestCase
  setup { @user = users(:babyoda) }

  test "renders each year with correctly user link" do
    calendar_list = stub(active_years: [2018, 2019, 2020])
    @user.stubs(:calendars).returns(calendar_list)

    render("users/years_side_menu", user: @user, selected_year: 2019)

    assert_select "a" do |links|
      assert_equal 3, links.size

      assert_equal "2020", links[0].text
      assert_equal "2019", links[1].text
      assert_equal "2018", links[2].text
    end
  end

  test "sets active year with given selected year" do
    calendar_list = stub(active_years: [2019, 2020])
    @user.stubs(:calendars).returns(calendar_list)

    render("users/years_side_menu", user: @user, selected_year: 2020)
    assert_select "a.is-active", text: "2020"

    render("users/years_side_menu", user: @user, selected_year: 2019)
    assert_select "a.is-active", text: "2019"
  end
end
