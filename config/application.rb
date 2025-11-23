require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MalHeatmap
  class Application < Rails::Application
    config.load_defaults 8.1
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

    config.active_job.queue_adapter = :solid_queue
    config.active_job.queue_name = :within_30_seconds
    config.solid_queue.connects_to = { database: { writing: :queue } }

    config.active_storage.service = :local
    config.active_storage.variant_processor = :vips

    config.active_storage.queues.analysis = :within_3_minutes
    config.active_storage.queues.purge = :within_3_minutes
    config.active_storage.queues.mirror = :within_3_minutes
    config.active_storage.queues.transform = :within_3_minutes

    config.assets.compile = true
    config.assets.paths << Rails.root.join("vendor/assets")

    config.assets.configure do |env|
      env.export_concurrent = false
    end

    config.middleware.insert_before ActionDispatch::Static, Rack::Deflater

    config.action_mailer.default_options = { from: "no-reply@malheatmap.com" }

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
