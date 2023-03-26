require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MalHeatmap
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = "UTC"
    config.autoload_paths << Rails.root.join("lib")

    config.active_record.default_timezone = :utc
    config.active_record.schema_format = :sql

    config.generators.orm :active_record, primary_key_type: :bigint
    config.generators.test_framework :test_unit, fixture: true
    config.generators.template_engine = :erb

    config.action_cable.mount_path = "/cable"

    config.active_storage.queues.analysis = nil
    config.active_storage.queues.purge = nil
    config.active_storage.queues.mirror = nil

    config.action_dispatch.cookies_serializer = :json
    config.filter_parameters += [:password]

    # config.exceptions_app = routes

    config.redis = config_for(:redis)
    config.cache_store = :redis_cache_store, config_for(:redis)
    config.session_store :cookie_store, expire_after: 1.week

    config.crawler = config_for(:crawler)
    config.analytics = config_for(:analytics)
    config.geocoder = config_for(:geocoder)
    config.mal_api = config_for(:mal_api)

    config.skylight.probes += %w[redis]

    config.active_storage.service = :local

    config.assets.compile = true
    config.assets.paths << Rails.root.join("vendor/assets")
  end
end

ActiveSupport::Deprecation.disallowed_warnings = :all
ActiveSupport::Deprecation.disallowed_behavior = :log
