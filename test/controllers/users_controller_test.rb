require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  class ShowTest < ActionDispatch::IntegrationTest
    setup do
      travel_to Time.zone.local(2020, 5, 2)

      @user = users(:babyoda)
      @user.update_columns(created_at: Time.current, updated_at: Time.current)
    end

    test "returns success" do
      get user_url(@user)

      assert_response :success
    end

    test "filters activities by year" do
      skip("needs refactor")

      @user.activities.create!(
        [
          { item: items(:naruto), date: Date.new(2019, 1, 1), amount: 1 },
          { item: items(:naruto), date: Date.new(2020, 1, 1), amount: 1 }
        ]
      )

      get user_url(@user, year: 2019)

      assert_select ".years-menu"

      assert_select "#2019-01-01", 1
      assert_select "#2020-01-01", 0

      get user_url(@user, year: 2020)

      assert_select "#2019-01-01", 0
      assert_select "#2020-01-01", 1
    end

    test "renders each year on years menu since user has been subscribed even if there is no activity in it" do
      @user.activities.create!(item: items(:naruto), date: Date.new(2021, 1, 1), amount: 1)
      travel_to Time.zone.local(2022, 10, 1)

      get user_url(@user)

      assert_select ".years-menu > ul > li > a" do |elements|
        assert %w[2020 2021 2022], elements.map(&:text)
      end
    end

    test "renders timeline activities dates ordered as desc" do
      skip("needs refactor")

      travel_to Time.zone.local(2020, 12, 1)

      @user.activities.create!(
        [
          { item: items(:bleach), date: Date.new(2020, 5, 1), amount: 1 },
          { item: items(:bleach), date: Date.new(2020, 5, 2), amount: 1 },
          { item: items(:bleach), date: Date.new(2020, 6, 1), amount: 1 },
          { item: items(:bleach), date: Date.new(2020, 6, 2), amount: 1 },
          { item: items(:bleach), date: Date.new(2020, 7, 1), amount: 1 },
          { item: items(:bleach), date: Date.new(2020, 7, 2), amount: 1 }
        ]
      )

      get user_url(@user)

      assert_select ".timeline"
      assert_select ".timeline-item/@id" do |elements|
        expected_items = %w[2020-07-02 2020-07-01 2020-06-02 2020-06-01 2020-05-02 2020-05-01]
        assert_equal expected_items, elements.map(&:value)
      end
    end

    test "renders the calendar range respecting the user time zone" do
      skip("needs refactor")

      user = users(:anderson)
      travel_to Time.zone.local(2020, 10, 4, 2)
      user.update_columns(created_at: Time.current, updated_at: Time.current)

      get user_url(user)

      assert_select ".calendar > .squares > .square" do |elements|
        assert_equal "2020-10-03", elements.last.attr("data-date")
        assert_equal "2019-09-29", elements.first.attr("data-date")
      end
    end

    test "renders calendar legend correctly" do
      skip("needs refactor")

      get user_url(@user)

      assert_select ".legend > .square", 5 do |elements|
        elements.each_with_index do |element, index|
          assert_equal index.to_s, element.attr("data-level")
          assert element.attr("title").present?
        end
      end
    end

    test "does not render the timeline when user does not have any activity" do
      skip("needs refactor")

      get user_url(@user)

      assert_select ".timeline", 0
      assert_select ".years-menu", 1
      assert_select "p", /#{@user.username} does not have any activity in 2020/
    end

    test "renders the years menu if user has any activity in other year than the selected" do
      @user.activities.create!(item: items(:naruto), amount: 1, date: Date.new(2019, 1, 1))

      get user_url(@user, year: 2020)

      assert_select ".years-menu"
    end
  end
end
