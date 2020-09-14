class HealthCheckController < ApplicationController
  http_basic_authenticate_with(
    name: Rails.application.credentials.health_check[:username],
    password: Rails.application.credentials.health_check[:password]
  )

  def index
    if sidekiq_online?
      head :ok
    else
      head :service_unavailable
    end
  end

  private

  def sidekiq_online?
    Sidekiq::ProcessSet.new.size.positive?
  end
end
