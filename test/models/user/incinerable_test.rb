require "test_helper"

class User::IncinerableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:babyoda)
  end

  test "incinerate! deletes all user data" do
    item = items(:naruto)
    3.times { |i| @user.entries.create!(item: item, amount: 1, timestamp: Time.current + i.day) }
    3.times { |i| @user.activities.create!(item: item, date: Time.current + i.day, amount: 1) }

    assert_equal 3, @user.entries.count
    assert_equal 3, @user.activities.count

    @user.incinerate!

    assert_raise(ActiveRecord::RecordNotFound) { @user.reload }
    assert_equal 0, Entry.where(user_id: @user.id).count
    assert_equal 0, Activity.where(user_id: @user.id).count
  end
end
