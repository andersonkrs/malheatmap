redis_config = Rails.configuration.redis.slice(:url, :timeout)

Sidekiq.configure_client { |config| config.redis = redis_config }

Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new

  Sidekiq.logger.level = Rails.configuration.log_level
  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger

  config.on(:startup) do
    if Rails.env.production?
      Sidekiq.schedule = YAML.load_file(Rails.root.join("config/sidekiq_scheduler.yml"))
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end

  config.capsule("default") do |cap|
    cap.concurrency = 5
    cap.queues = %w[default]
  end

  config.capsule("low") do |cap|
    cap.concurrency = 2
    cap.queues = %w[low]
  end

  config.capsule("single_thread") do |cap|
    cap.concurrency = 1
    cap.queues = %w[logging active_storage]
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
