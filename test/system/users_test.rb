require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)

    @last_year = Time.zone.today.last_year.year

    @manga = create(:activity, :manga, user: @user, date: Time.zone.today)
    @anime = create(:activity, :anime, user: @user, date: 1.year.ago)
  end

  test "user can navigate through active years" do
    visit user_url(@user)

    assert_text @manga.name
    assert_text @anime.name

    click_on @last_year.to_s
    assert_current_path user_path(@user, year: @last_year)

    assert_text @anime.name
    assert_no_text @manga.name
  end
end
