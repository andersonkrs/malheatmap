require "application_system_test_case"

class SubscriptionsTest < ApplicationSystemTestCase
  setup do
    visit subscriptions_url
  end

  test "shows required username notification when submiting without type username" do
    click_on "Subscribe"

    assert_text "Username can't be blank"
  end

  test "shows invalid username notification when submiting invalid username format" do
    fill_in "username", with: "/ $ anns2!"

    click_on "Subscribe"

    assert_text "Username is invalid"
  end

  test "shows profile not found notification when submiting invalid username" do
    fill_in "username", with: "asdkkiok1i2k3io1k"

    click_on "Subscribe"
    assert_text "Please wait..."

    perform_enqueued_jobs

    assert_text <<~MESSAGE.strip
      Profile not found for username asdkkiok1i2k3io1k. Please check if you typed it correctly.
    MESSAGE
  end

  test "redirects to user profile when username is already subscribed" do
    user = create(:user)
    fill_in "username", with: user.username

    click_on "Subscribe"

    assert_current_path user_path(user.username)
  end

  test "redirects to user profile when username is valid but not subscribed yet" do
    fill_in "username", with: "https://myanimelist.net/profile/animeisgood8"

    click_on "Subscribe"
    assert_text "Please wait..."

    perform_enqueued_jobs
    assert_current_path user_path("animeisgood8")
  end
end
