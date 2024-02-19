require "test_helper"

class HealthCheckControllerTest < ActionDispatch::IntegrationTest
  setup { @authorization = ActionController::HttpAuthentication::Basic.encode_credentials("secret", "secret") }

  test "blocks unauthorized requests" do
    get health_check_path

    assert_response :unauthorized
  end

  test "returns service unavailable if queues are down" do
    SolidQueue::Process.create!(last_heartbeat_at: 3.minutes.ago, kind: "Supervisor", pid: 123)

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :service_unavailable
  end

  test "returns ok if the queueing backend is up" do
    SolidQueue::Process.create!(last_heartbeat_at: 10.seconds.ago, kind: "Supervisor", pid: 123)

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :ok
  end
end
