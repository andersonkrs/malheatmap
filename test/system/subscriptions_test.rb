require "application_system_test_case"

class SubscriptionsTest < ApplicationSystemTestCase
  include VCRCassettes

  setup do
    visit subscriptions_url
  end

  test "shows required username notification when submitting without type username" do
    click_on "Subscribe"

    assert_text "Username can't be blank"
  end

  test "shows invalid username notification when submitting invalid username format" do
    fill_in "subscription[username]", with: "/ $ anns2!"

    click_on "Subscribe"

    assert_text "Username is invalid"
  end

  test "shows profile not found notification when submitting invalid username" do
    fill_in "subscription[username]", with: "asdkkiok1i2k3io1k"

    click_on "Subscribe"
    assert_text(/Please wait/)

    perform_enqueued_jobs

    assert_current_path(subscriptions_path)
    assert_text(/Profile not found for username/)
  end

  test "redirects to user profile when username is already subscribed" do
    user = users(:babyoda)
    fill_in "subscription[username]", with: user.username

    click_on "Subscribe"

    assert_current_path user_path(user.username)
  end

  test "redirects to user profile when username is valid but not subscribed yet" do
    fill_in "subscription[username]", with: "https://myanimelist.net/profile/animeisgood8"

    click_on "Subscribe"
    assert_text(/Please wait/)

    perform_enqueued_jobs
    assert_current_path user_path("animeisgood8")
  end

  test "shows a hint when subscribing a user without entries" do
    fill_in "subscription[username]", with: "https://myanimelist.net/profile/jibaku"

    click_on "Subscribe"
    assert_text(/Please wait/)

    perform_enqueued_jobs
    assert_text(/does not have any activity/)
  end
end
