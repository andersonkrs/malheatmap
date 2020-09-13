require "test_helper"

class SubscriptionFormTest < ActiveSupport::TestCase
  setup do
    @form = SubscriptionForm.new(username: "https://myanimelist.net/profile/andersonkrs")
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

  test "cleans username after validations" do
    @form.validate

    assert_equal "andersonkrs", @form.username
  end

  test "sets username as nil when it is an invalid url" do
    @form.username = "12o3ko12412ç4. "

    @form.validate

    assert_nil @form.username
  end

  test "calls create subscription service with cleaned username" do
    subscription = create(:subscription)
    result_mock = Minitest::Mock.new
    result_mock.expect(:subscription, subscription)

    service_mock = lambda { |username:|
      assert_equal "andersonkrs", username
      result_mock
    }

    Subscription::Create.stub(:call!, service_mock) do
      assert @form.save
      assert_equal subscription.id, @form.id
      result_mock.verify
    end
  end

  test "does not save if the user is already subscribed" do
    create(:user, username: "andersonkrs")

    assert_not @form.save
    assert @form.errors.of_kind?(:username, :taken)
  end
end
