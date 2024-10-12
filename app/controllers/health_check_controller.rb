class HealthCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  def index
    active_workers = SolidQueue::Process
      .where(kind: "Worker")
      .where("last_heartbeat_at >= ?", SolidQueue.process_alive_threshold.ago)

    return head :service_unavailable if active_workers.none?

    head :ok
  end
end
