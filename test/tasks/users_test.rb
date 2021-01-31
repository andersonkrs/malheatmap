require "test_helper"

class UsersTasksTest < ActiveSupport::TestCase
  test "creates a user and move all old user's entries to it" do
    old_user = users(:anderson)
    old_user.entries.create!(item: items(:naruto), timestamp: Time.zone.now, amount: 1)
    old_user.entries.create!(item: items(:boruto), timestamp: Time.zone.now, amount: 2)
    old_user.entries.create!(item: items(:cowboy_bebop), timestamp: Time.zone.now, amount: 10)

    Rake::Task["users:merge"].invoke(old_user.username, "NewUser")

    created_user = User.find_by(username: "NewUser")
    assert created_user
    assert_equal 3, created_user.entries.count
    assert created_user.entries.exists?(id: old_user.entries.map(&:id))
    assert_enqueued_with job: User::CrawlDataJob, args: [created_user]
    assert_not User.exists?(id: old_user.id)
  end

  test "moves the old user's entries to the new user when it already exists" do
    old_user = users(:anderson)
    old_user.entries.create!(item: items(:naruto), timestamp: Time.zone.now, amount: 1)
    old_user.entries.create!(item: items(:boruto), timestamp: Time.zone.now, amount: 2)
    old_user.entries.create!(item: items(:cowboy_bebop), timestamp: Time.zone.now, amount: 10)

    new_user = users(:babyoda)
    new_user.entries.create!(item: items(:naruto), timestamp: Time.zone.yesterday, amount: 1)
    new_user.entries.create!(item: items(:boruto), timestamp: Time.zone.yesterday, amount: 2)

    assert_changes -> { new_user.entries.count }, from: 2, to: 5 do
      Rake::Task["users:merge"].invoke(old_user.username, new_user.username)
    end

    assert_not User.exists?(id: old_user.id)
    assert_nil new_user.reload.checksum
    assert_enqueued_with job: User::CrawlDataJob, args: [new_user]
  end

  test "does not do anything if the old user name does not exit" do
    Rake::Task["users:merge"].invoke("old_user", "new_user")

    assert_not User.exists?(username: "old_user")
    assert_not User.exists?(username: "new_user")
  end
end
