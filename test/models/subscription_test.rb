require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @username = "myuser"
    @subscription = Subscription.new(username: @username)
  end

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
end
