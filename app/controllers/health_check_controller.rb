class HealthCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  QUEUE_LAST_HEARTBEAT_INTERVAL = 2.minutes

  def index
    if solid_queue_online?
      head :ok
    else
      head :service_unavailable
    end
  end

  private

  def solid_queue_online?
    SolidQueue::Process.where("last_heartbeat_at >= ?", QUEUE_LAST_HEARTBEAT_INTERVAL.ago).exists?
  end
end
