class ThreadedBrowserMiddleware
  def call(_worker, _message, _queue)
    BrowserSession.current = Sidekiq.options[:browser]
    yield
  end
end

require_relative "../../lib/browser_session"

Sidekiq.configure_server do |config|
  config.log_formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new

  Sidekiq.logger.level = Rails.configuration.log_level
  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger

  config.on(:startup) do
    if Rails.env.production?
      Sidekiq.schedule = YAML.load_file("config/schedule.yml")
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end

    config.options[:browser] = BrowserSession.new_browser
  end

  config.on(:quiet) do
    config.options[:browser]&.quit
  end

  config.server_middleware do |chain|
    chain.add ThreadedBrowserMiddleware
  end
end

unless Sidekiq.server?
  require "sidekiq/web"
  require "sidekiq-scheduler/web"

  if Rails.env.production?
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
end
