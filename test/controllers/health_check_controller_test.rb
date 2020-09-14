require "test_helper"

class HealthCheckControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      "secret",
      "secret"
    )
  end

  test "blocks unauthorized requests" do
    get health_check_path

    assert_response :unauthorized
  end

  test "returns service unavailable if sidekiq is down" do
    process_mock = Minitest::Mock.new
    process_mock.expect(:size, 0)

    Sidekiq::ProcessSet.stub(:new, process_mock) do
      get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }
    end

    assert_response :service_unavailable
    assert process_mock.verify
  end

  test "returns ok if sidekiq is up" do
    process_mock = Minitest::Mock.new
    process_mock.expect(:size, 1)

    Sidekiq::ProcessSet.stub(:new, process_mock) do
      get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }
    end

    assert_response :ok
    assert process_mock.verify
  end
end
