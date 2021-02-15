require "test_helper"

class UsersTasksTest < ActiveSupport::TestCase
  test "moves the old user's entries to the new user" do
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
    assert_raises ActiveRecord::RecordNotFound do
      Rake::Task["users:merge"].invoke("old_user", "new_user")
    end

    assert_not User.exists?(username: "old_user")
    assert_not User.exists?(username: "new_user")
  end

  test "does not do anything if the new user name does not exit" do
    old_user = users(:anderson)
    old_user.entries.create!(item: items(:naruto), timestamp: Time.zone.now, amount: 1)

    assert_raises ActiveRecord::RecordNotFound do
      Rake::Task["users:merge"].invoke(old_user.username, "new_user")
    end

    assert old_user.reload.present?
    assert_not User.exists?(username: "new_user")
  end
end
