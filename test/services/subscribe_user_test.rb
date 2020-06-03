require "test_helper"

class SubscribeUserTest < ActiveSupport::TestCase
  setup do
    @subscription = create(:subscription)
    @service = SubscribeUser.set(subscription: @subscription)
  end

  test "returns created user for giving subscription" do
    UserData::Update.stub(:call!, nil) do
      result = @service.call

      assert result.success?
      assert User.exists?(username: @subscription.username)
      assert result.user.present?
    end
  end

  test "does not create user when fetching fails" do
    fetch_mock = proc {
      context_mock = Minitest::Mock.new
      context_mock.expect(:failure?, true)

      raise Patterns::Service::Failure, context_mock
    }

    UserData::Update.stub(:call!, fetch_mock) do
      result = @service.call

      assert result.failure?
      assert_not User.exists?(username: @subscription.username)
    end
  end
end
