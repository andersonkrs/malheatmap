require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup { @user = users(:babyoda) }

  test "user can navigate through active years" do
    last_year = Time.zone.today.last_year.year

    manga = @user.activities.create!(amount: 1, item: items(:cowboy_bebop), date: Time.zone.today)
    anime = @user.activities.create!(amount: 1, item: items(:naruto), date: 1.year.ago)

    visit user_url(@user)

    assert_text(/#{manga.name}/)
    assert_text(/#{anime.name}/)

    click_on last_year.to_s
    assert_current_path user_path(@user, year: last_year)

    assert_text(/#{anime.name}/)
    assert_no_text(/#{manga.name}/)
  end
end
