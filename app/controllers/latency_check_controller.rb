class LatencyCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  def show
    queue = SolidQueue::Queue.find_by_name(params.require(:queue))

    if queue.latency > threshold
      response = { queue: queue.name, latency: ActiveSupport::Duration.build(queue.latency.to_i).inspect }
      render json: response, status: :service_unavailable
    else
      head :ok
    end
  end

  private

  def threshold
    params[:threshold_in_seconds].to_i.seconds
  end
end
