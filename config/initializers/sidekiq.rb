Sidekiq.configure_client do |config|
  config.redis = {
    size: 2,
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
  }

  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger
end

unless Sidekiq.server?
  require "sidekiq/web"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:username])
    ) & ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:password])
    )
  end
end
