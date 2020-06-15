require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

require "view_component/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MalHeatmap
  class Application < Rails::Application
    config.load_defaults 6.0
    config.time_zone = "UTC"
    config.autoload_paths << Rails.root.join("lib")

    config.active_record.default_timezone = :utc
    config.active_record.schema_format = :sql

    config.generators.orm :active_record, primary_key_type: :uuid
    config.generators.test_framework :test_unit, fixture: false
    config.generators.factory_bot true
    config.generators.template_engine = :slim

    config.action_cable.mount_path = "/cable"

    config.action_dispatch.cookies_serializer = :json
    config.filter_parameters += [:password]

    config.crawler = config_for(:crawler)
  end
end
