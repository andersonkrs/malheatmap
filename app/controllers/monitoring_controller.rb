# Public healthcheck for containers
# When solid queue is down or there is a stuck job, restart everything
class MonitoringController < ApplicationController
  def show
    queues = SolidQueue::Helper.queues_from_config

    queues.each do |queue|
      unless SolidQueue::Helper.active_processes_for_queue?(queue_name: queue)
        render json: { message: "No workers active for queue #{queue}" }, status: :service_unavailable
        return
      end

      if SolidQueue::Helper.stuck_executions_for_queue?(queue_name: queue, threshold: 2.hours)
        render json: { message: "Stuck executions on #{queue}" }, status: :service_unavailable
        return
      end
    end

    head :ok
  end
end
