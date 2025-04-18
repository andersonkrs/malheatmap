require "test_helper"

class HealthCheckControllerTest < ActionDispatch::IntegrationTest
  setup { @authorization = ActionController::HttpAuthentication::Basic.encode_credentials("secret", "secret") }

  test "blocks unauthorized requests" do
    get health_check_path

    assert_response :unauthorized
  end

  test "returns service unavailable if queues are down" do
    SolidQueue::Process.create!({
      name: "test",
      last_heartbeat_at: 1.hour.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "screenshots,default,active_storage,low,logging"
      }
    })

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :service_unavailable
  end

  test "returns ok if the queueing backend is up" do
    SolidQueue::Process.create!({
      name: "test",
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "screenshots,default"
      }
    })

    SolidQueue::Process.create!({
      name: "test",
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 456,
      metadata: {
        queues: "active_storage,low,logging,solid_queue_recurring"
      }
    })

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :ok
  end
end
