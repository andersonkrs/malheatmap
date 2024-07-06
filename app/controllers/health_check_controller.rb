class HealthCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  def index
    queues = SolidQueue::Helper.queues_from_config

    queues.each do |queue|
      unless SolidQueue::Helper.active_processes_for_queue?(queue_name: queue)
        render json: { message: "No workers active for queue #{queue}" }, status: :service_unavailable
        return
      end

      if SolidQueue::Helper.stuck_executions_for_queue?(queue_name: queue, threshold: 3.hours)
        render json: { message: "Stuck executions on #{queue}" }, status: :service_unavailable
        return
      end
    end

    head :ok
  end
end
