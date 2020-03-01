require "test_helper"

class UpdateServiceTest < ActiveSupport::TestCase
  setup do
    @username = "myusername"
    @crawler_service_mock = MiniTest::Mock.new
  end

  def call
    UpdateService.call(@username, @crawler_service_mock)
  end

  def setup_success_response
    response = {
      status: :success,
      message: "",
      profile: {
        avatar_url: "http://dummy/avatar"
      },
      entries: [
        {
          timestamp: "2019-12-06T15:00:00",
          amount: 1,
          item_id: 121,
          item_name: "Death Note",
          item_kind: "manga"
        },
        {
          timestamp: "2019-12-06T16:11:03",
          amount: 6,
          item_id: 5,
          item_name: "One Punch Man",
          item_kind: "anime"
        }
      ]
    }

    @crawler_service_mock.expect :call, response, [@username]
  end

  def setup_error_response
    response = {
      status: :error,
      message: "Something went wrong"
    }

    @crawler_service_mock.expect :call, response, [@username]
  end

  test "returns status success when crawler performs without errros" do
    setup_success_response

    result = call

    assert_equal result, status: :success, message: ""
  end

  test "creates user record and inserts all entries when it does not exist" do
    setup_success_response

    call

    user = User.includes(:entries).find_by(username: @username)
    assert user.checksum.present?
    assert_equal "http://dummy/avatar", user.avatar_url
    assert_equal 2, user.entries.size

    entry = user.entries.first
    assert_equal DateTime.new(2019, 12, 6, 16, 11, 3), entry.timestamp
    assert_equal 6, entry.amount
    assert_equal "One Punch Man", entry.item_name
    assert entry.anime?

    entry = user.entries.last
    assert_equal DateTime.new(2019, 12, 6, 15, 0, 0), entry.timestamp
    assert_equal 1, entry.amount
    assert_equal "Death Note", entry.item_name
    assert entry.manga?
  end

  test "generates new checksum when user already exists" do
    user = create(:user, username: @username)
    setup_success_response

    call

    assert_changes -> { user.checksum } do
      user.reload
    end
  end

  test "inserts all new entries to existing user when it already exists" do
    user = create(:user, username: @username)
    setup_success_response

    assert_changes -> { user.entries.count }, from: 0, to: 2 do
      call
    end
  end

  test "inserts just the new entries when user already has entries with more than 3 weeks" do
    user = create(:user, username: @username)
    create(:entry, user: user, timestamp: 22.days.ago.in_time_zone)
    setup_success_response

    assert_changes -> { user.entries.count }, from: 1, to: 3 do
      call
    end
  end

  test "does not update user's checksum when it does not have new entries" do
    setup_success_response
    user = create(:user, username: @username, checksum: "e7190cb4643a29cb58fb5bc175627152")

    result = call

    assert_equal(
      { status: :not_processed, message: "User #{@username} hasn't new entries" },
      result
    )

    assert_no_changes -> { user.checksum } do
      user.reload
    end
  end

  test "returns error status when someting goes wrong with crawler service" do
    setup_error_response

    result = call

    assert_equal({ status: :error, message: "Something went wrong" }, result)
  end

  test "does not create user's record when crawler returns an error" do
    setup_error_response

    call

    assert_not User.exists?(username: @username)
  end
end
