class ThreadedBrowserMiddleware
  def call(_worker, _message, _queue)
    BrowserSession.current = Sidekiq.default_configuration[:browser]
    yield
  end
end

require_relative "../../lib/browser_session"

Sidekiq.configure_client { |config| config.redis = { url: Rails.configuration.redis[:url] } }

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.redis[:url] }

  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new

  Sidekiq.logger.level = Rails.configuration.log_level
  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger

  config.on(:startup) { config[:browser] = BrowserSession.new_browser }

  config.on(:quiet) { config[:browser]&.quit }

  config.server_middleware { |chain| chain.add ThreadedBrowserMiddleware }

  config.capsule("default") do |cap|
    cap.concurrency = 5
    cap.queues = %w[default]
  end

  config.capsule("low") do |cap|
    cap.concurrency = 2
    cap.queues = %w[low]
  end
end

unless Sidekiq.server?
  require "sidekiq/web"
  require "sidekiq-scheduler/web"

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(username),
        Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:username])
      ) &
        ActiveSupport::SecurityUtils.secure_compare(
          Digest::SHA256.hexdigest(password),
          Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:password])
        )
    end
  end
end

Sidekiq.strict_args!(false)
