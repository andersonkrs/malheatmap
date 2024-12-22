class LatencyCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  def show
    queue = SolidQueue::Queue.find_by_name(params.require(:queue))
    response = { queue: queue.name, latency: queue.human_latency }

    if queue.latency > threshold
      render json: response, status: :service_unavailable
    else
      render json: response, status: :ok
    end
  end

  private

  def threshold
    params[:threshold_in_seconds].to_i.seconds
  end
end
