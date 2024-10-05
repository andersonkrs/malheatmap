require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MalHeatmap
  class Application < Rails::Application
    config.load_defaults 8.0
    config.time_zone = "UTC"
    config.autoload_paths << Rails.root.join("lib")

    config.active_record.default_timezone = :utc
    config.active_record.schema_format = :ruby

    config.generators.orm :active_record, primary_key_type: :bigint
    config.generators.test_framework :test_unit, fixture: true
    config.generators.template_engine = :erb

    config.action_cable.mount_path = "/cable"

    config.action_dispatch.cookies_serializer = :json

    config.session_store :cookie_store, expire_after: 1.week, key: "_malheatmap_session_v1"

    config.crawler = config_for(:crawler)
    config.analytics = config_for(:analytics)
    config.geocoder = config_for(:geocoder)
    config.mal_api = config_for(:mal_api)

    config.active_storage.service = :local
    config.active_storage.variant_processor = :vips
    config.active_storage.queues.analysis = :active_storage
    config.active_storage.queues.purge = :active_storage
    config.active_storage.queues.mirror = :active_storage

    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.connects_to = { database: { writing: :queue } }

    config.mission_control.jobs.base_controller_class = "AdminController"

    config.assets.compile = true
    config.assets.paths << Rails.root.join("vendor/assets")

    config.assets.configure do |env|
      env.export_concurrent = false
    end

    config.middleware.insert_before ActionDispatch::Static, Rack::Deflater

    config.action_mailer.default_options = { from: "no-reply@malheatmap.com" }
  end
end
