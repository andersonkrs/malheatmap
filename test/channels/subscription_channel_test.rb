require "test_helper"

class SubscriptionChannelTest < ActionCable::Channel::TestCase
  test "subscribes with correct process id" do
    process = create(:subscription)

    subscribe process_id: process.id

    assert subscription.confirmed?
    assert_has_stream_for process
  end

  test "does not stream with incorret process id" do
    subscribe process_id: "1j2n3j1n24jn1j3nr"

    assert_no_streams
  end

  test "does not subscribe without process id" do
    subscribe

    assert subscription.rejected?
  end

  test "does not subscribe if process status is success" do
    process = create(:subscription, status: :success)

    subscribe process_id: process.id

    assert subscription.rejected?
  end

  test "does not subscribe if process status is error" do
    process = create(:subscription, status: :error)

    subscribe process_id: process.id

    assert subscription.rejected?
  end
end
