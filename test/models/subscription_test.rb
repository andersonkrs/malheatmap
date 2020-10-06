require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = build(:subscription, username: "https://myanimelist.net/profile/andersonkrs")
  end

  context "validations" do
    should validate_presence_of(:username)
    should allow_value("andersonkrs").for(:username)
    should allow_value("https://myanimelist.net/profile/andersonkrs").for(:username)
    should allow_value("http://myanimelist.net/profile/andersonkrs").for(:username)
    should allow_value("http://myanimelist.net/profile/andersonkrs/").for(:username)
    should allow_value("https://myanimelist.net/history/andersonkrs").for(:username)
    should allow_value("http://myanimelist.net/history/andersonkrs/").for(:username)

    should_not allow_value("andersonkrs#!@").for(:username)
    should_not allow_value("andersonkrs/").for(:username)
    should_not allow_value("andersonkrs.nicolas").for(:username)
    should_not allow_value("https://myanimelist.net/profile/").for(:username)
    should_not allow_value("https://myanimelist.net/profile/#!@").for(:username)
    should_not allow_value("https://myanimelist.com/profile/user").for(:username)
    should_not allow_value("https://fakeurl.com/profile/user").for(:username)
    should_not allow_value("https://fakeurl.com/profile/user/andersonkrs.nicolas").for(:username)
  end

  test "cleans username after validations" do
    @subscription.validate

    assert_equal "andersonkrs", @subscription.username
  end

  test "sets username as nil when it is an invalid url" do
    @subscription.username = "12o3ko12412ç4. "

    @subscription.validate

    assert_nil @subscription.username
  end

  test "does not save if the user is already subscribed" do
    create(:user, username: "andersonkrs")

    assert_not @subscription.save
    assert @subscription.errors.of_kind?(:username, :taken)
  end
end
