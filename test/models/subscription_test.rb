require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:username)
    should allow_value("andersonkrs").for(:username)
    should allow_value("https://myanimelist.net/profile/andersonkrs").for(:username)
    should allow_value("http://myanimelist.net/profile/andersonkrs").for(:username)
    should allow_value("http://myanimelist.net/profile/andersonkrs/").for(:username)

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
    subscription = build(:subscription, username: "http://myanimelist.net/profile/andersonkrs/")

    subscription.validate

    assert_equal "andersonkrs", subscription.username
  end

  test "sets username as nil when it is an invalid url" do
    subscription = build(:subscription, username: "%@#42 12 l2")

    subscription.validate

    assert_nil subscription.username
  end
end
