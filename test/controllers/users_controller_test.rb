require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  class ShowTest < ActionDispatch::IntegrationTest
    setup do
      travel_to Time.zone.local(2020, 5, 2)

      @user = create(:user)
      @anime_item = create(:item, mal_id: 1, kind: :anime, name: "Death Note")
      @manga_item = create(:item, mal_id: 2, kind: :manga, name: "Naruto")
    end

    test "returns success" do
      get user_url(@user)

      assert_response :success
    end

    test "renders graph squares correctly" do
      travel_to Time.zone.local(2020, 5, 9)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 1), amount: 1)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 2), amount: 5)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 3), amount: 9)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 4), amount: 13)

      get user_url(@user, year: 2020)

      assert_select ".graph > .squares > .square" do |elements|
        assert_equal 371, elements.size

        assert_equal "2019-05-05", elements.first.attr("data-date")
        assert_equal "2020-05-09", elements.last.attr("data-date")
      end

      assert_select ".graph > .squares > .square[data-level='0']", 367

      assert_select ".graph > .squares > .square[data-level='1']", 1 do |element|
        assert_select element.first, "a/@href", "#2020-01-01"
        assert_equal "One activity on January 01, 2020", element.first.attr("title")
      end

      assert_select ".graph > .squares > .square[data-level='2']", 1 do |element|
        assert_select element.first, "a/@href", "#2020-01-02"
        assert_equal "5 activities on January 02, 2020", element.first.attr("title")
      end

      assert_select ".graph > .squares > .square[data-level='3']", 1 do |element|
        assert_select element.first, "a/@href", "#2020-01-03"
        assert_equal "9 activities on January 03, 2020", element.first.attr("title")
      end

      assert_select ".graph > .squares > .square[data-level='4']", 1 do |element|
        assert_select element.first, "a/@href", "#2020-01-04"
        assert_equal "13 activities on January 04, 2020", element.first.attr("title")
      end
    end

    test "renders graph months correctly" do
      travel_to Time.zone.local(2020, 5, 9)

      get user_url(@user, year: 2020)

      assert_select ".graph > .months > .month" do |elements|
        assert_equal elements.size, 13

        expected_months = %w[May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr May]
        assert_equal expected_months, elements.map(&:text)
      end
    end

    test "renders graph legend correctly" do
      get user_url(@user)

      assert_select ".legend > .square", 5 do |elements|
        elements.each_with_index do |element, index|
          assert_equal index.to_s, element.attr("data-level")
          assert element.attr("title").present?
        end
      end
    end

    test "filters activities by year" do
      create(:activity, item: @anime_item, user: @user, date: Date.new(2019, 1, 1), amount: 1)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 1), amount: 1)

      get user_url(@user, year: 2019)

      assert_select "#2019-01-01", 1
      assert_select "#2020-01-01", 0

      get user_url(@user, year: 2020)

      assert_select "#2019-01-01", 0
      assert_select "#2020-01-01", 1
    end

    test "renders timeline activities dates ordered as desc" do
      travel_to Time.zone.local(2020, 12, 1)

      create(:activity, user: @user, date: Date.new(2020, 5, 1))
      create(:activity, user: @user, date: Date.new(2020, 5, 2))
      create(:activity, user: @user, date: Date.new(2020, 6, 1))
      create(:activity, user: @user, date: Date.new(2020, 6, 2))
      create(:activity, user: @user, date: Date.new(2020, 7, 1))
      create(:activity, user: @user, date: Date.new(2020, 7, 2))

      get user_url(@user)

      assert_select ".timeline-item/@id" do |elements|
        expected_items = %w[2020-07-02 2020-07-01 2020-06-02 2020-06-01 2020-05-02 2020-05-01]
        assert_equal expected_items, elements.map(&:value)
      end
    end

    test "renders timeline markers correctly" do
      travel_to Time.zone.local(2020, 12, 1)

      create(:activity, user: @user, date: Date.new(2020, 1, 1))
      create(:activity, user: @user, date: Date.new(2020, 2, 1))
      create(:activity, user: @user, date: Date.new(2020, 3, 1))
      create(:activity, user: @user, date: Date.new(2020, 4, 1))
      create(:activity, user: @user, date: Date.new(2020, 7, 1))
      create(:activity, user: @user, date: Date.new(2020, 10, 1))

      get user_url(@user)

      assert_select ".header-marker/text()", "October"
      assert_select ".separator-marker/text()" do |elements|
        assert_equal %w[July April March February January], elements.map(&:text)
      end
      assert_select ".footer-marker/text()", "January"
    end

    test "renders grouped activities per day" do
      create(:activity, item: @anime_item, user: @user, date: Date.new(2019, 6, 1), amount: 1)
      create(:activity, item: @manga_item, user: @user, date: Date.new(2019, 6, 1), amount: 2)
      create(:activity, item: @manga_item, user: @user, date: Date.new(2019, 5, 1), amount: 12)

      get user_url(@user)

      assert_select "#2019-06-01" do
        assert_select "p.activity", 2

        assert_select "p.activity" do |elements|
          assert_select elements[0], "i/@class", "fas fa-tv"
          assert_select elements[0], "a/@href", "https://myanimelist.net/anime/1"
          assert_includes elements[0].text, "Death Note 1 episode"

          assert_select elements[1], "i/@class", "fas fa-book-reader"
          assert_select elements[1], "a/@href", "https://myanimelist.net/manga/2"
          assert_includes elements[1].text, "Naruto 2 chapters"
        end
      end

      assert_select "#2019-05-01" do
        assert_select ".activity", 1

        assert_select ".activity" do |elements|
          assert_select elements[0], "i/@class", "fas fa-book-reader"
          assert_select elements[0], "a/@href", "https://myanimelist.net/manga/2"
          assert_includes elements[0].text, "Naruto 12 chapters"
        end
      end
    end

    test "renders years links when user has activities in past years" do
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 6, 1), amount: 1)
      create(:activity, item: @manga_item, user: @user, date: Date.new(2019, 5, 1), amount: 1)

      get user_url(@user)

      assert_select ".year-link" do |elements|
        assert_equal elements.size, 2

        assert_includes user_url(@user, year: 2020), elements[0].attr("href")
        assert_includes user_url(@user, year: 2019), elements[1].attr("href")
      end
    end

    test "toggles active year" do
      create(:activity, item: @anime_item, user: @user, date: Date.new(2019, 1, 1), amount: 1)
      create(:activity, item: @anime_item, user: @user, date: Date.new(2020, 1, 1), amount: 1)

      get user_url(@user, year: 2019)
      assert_select ".year-link.is-active/text()", "2019"

      get user_url(@user, year: 2020)
      assert_select ".year-link.is-active/text()", "2020"
    end
  end
end
