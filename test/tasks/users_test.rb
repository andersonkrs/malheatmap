require "test_helper"

class UsersTasksTest < ActiveSupport::TestCase
  test "creates a user and move all old user's entries to it" do
    old_user = create(:user, entries: build_list(:entry, 10),
                             activities: build_list(:activity, 10))

    Rake::Task["users:merge"].invoke(old_user.username, "NewUser")

    created_user = User.find_by(username: "NewUser")
    assert created_user
    assert_equal 10, created_user.entries.count
    assert created_user.entries.exists?(id: old_user.entries.map(&:id))
    assert_enqueued_with job: User::CrawlDataJob, args: [created_user]
    assert_not User.exists?(id: old_user.id)
  end

  test "move the old user's entries to the new user when it already exists" do
    old_user = create(:user, entries: build_list(:entry, 3),
                             activities: build_list(:activity, 3))
    new_user = create(:user, entries: build_list(:entry, 2),
                             activities: build_list(:activity, 2))

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
