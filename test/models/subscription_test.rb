require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = Subscription.new(username: "https://myanimelist.net/profile/juan")
  end

  context "validations" do
    should validate_presence_of(:username)
    should allow_value("juan").for(:username)
    should allow_value("https://myanimelist.net/profile/juan").for(:username)
    should allow_value("http://myanimelist.net/profile/juan").for(:username)
    should allow_value("http://myanimelist.net/profile/juan/").for(:username)
    should allow_value("https://myanimelist.net/history/juan").for(:username)
    should allow_value("http://myanimelist.net/history/juan/").for(:username)

    should_not allow_value("juan#!@").for(:username)
    should_not allow_value("juan/").for(:username)
    should_not allow_value("juan.nicolas").for(:username)
    should_not allow_value("https://myanimelist.net/profile/").for(:username)
    should_not allow_value("https://myanimelist.net/profile/#!@").for(:username)
    should_not allow_value("https://myanimelist.com/profile/user").for(:username)
    should_not allow_value("https://fakeurl.com/profile/user").for(:username)
    should_not allow_value("https://fakeurl.com/profile/user/juan.nicolas").for(:username)
  end

  test "cleans username after validations" do
    @subscription.validate

    assert_equal "juan", @subscription.username
  end

  test "sets username as nil when it is an invalid url" do
    @subscription.username = "12o3ko12412ç4. "

    @subscription.validate

    assert_nil @subscription.username
  end

  test "does not save if the user is already subscribed" do
    @subscription.username = users(:babyoda).username

    assert_not @subscription.save
    assert @subscription.errors.of_kind?(:username, :taken)
  end
end
