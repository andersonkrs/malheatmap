require "test_helper"

class HealthCheckControllerTest < ActionDispatch::IntegrationTest
  setup { @authorization = ActionController::HttpAuthentication::Basic.encode_credentials("secret", "secret") }

  test "blocks unauthorized requests" do
    get health_check_path

    assert_response :unauthorized
  end

  test "returns service unavailable if queues are down" do
    SolidQueue::Process.create!({
      last_heartbeat_at: 1.hour.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "chrome,default,active_storage,low,logging"
      }
    })

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :service_unavailable
  end

  test "returns ok if the queueing backend is up" do
    SolidQueue::Process.create!({
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "chrome,default"
      }
    })

    SolidQueue::Process.create!({
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 456,
      metadata: {
        queues: "active_storage,low,logging"
      }
    })

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :ok
  end

  test "returns service unavailable if there is a stuck execution expired" do
    job = SolidQueue::Job.create!(queue_name: "default", class_name: "CronJob")
    process = SolidQueue::Process.create!({
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "chrome,default,active_storage,low,logging"
      }
    })
    process.claimed_executions.create(job: job, created_at: 6.hours.ago)

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :service_unavailable
  end

  test "returns ok if there is a stuck execution but not expired" do
    job = SolidQueue::Job.create!(queue_name: "backups", class_name: "CronJob")
    process = SolidQueue::Process.create!({
      last_heartbeat_at: 10.seconds.ago,
      kind: "Worker",
      pid: 123,
      metadata: {
        queues: "chrome,default,active_storage,low,logging"
      }
    })
    process.claimed_executions.create(job: job, created_at: (2.hours + 10.minutes).ago)

    get health_check_path, headers: { "HTTP_AUTHORIZATION" => @authorization }

    assert_response :ok
  end
end
