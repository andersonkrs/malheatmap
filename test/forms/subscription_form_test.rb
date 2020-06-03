require "test_helper"

class SubscriptionFormTest < ActiveSupport::TestCase
  setup do
    @form = SubscriptionForm.new(username: "andersonkrs")
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

  test "enqueues subscription job when saves" do
    assert @form.save

    subscription = Subscription.find_by(username: @form.username)
    assert_not subscription.processed?

    assert_enqueued_with job: SubscriptionJob, args: [subscription]
  end

  test "does not create any subscription when username is invalid" do
    @form.username = "aksjdiajsdamd 12ç .1 eq"

    assert_no_changes -> { Subscription.count } do
      @form.save
    end
  end

  test "does not enqueue any job when username is invalid" do
    @form.username = "ak -2- -3p "

    assert_no_enqueued_jobs do
      @form.save
    end
  end
end
