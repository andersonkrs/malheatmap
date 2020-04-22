require_relative "boot"

require "rails/all"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
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
    config.load_defaults 6.0
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("services")
    config.autoload_paths << Rails.root.join("presenters")
    config.generators.orm :active_record, primary_key_type: :uuid
    config.generators.test_framework :test_unit, fixture: false
    config.generators.factory_bot true
    config.active_record.schema_format = :sql
    config.action_cable.mount_path = "/cable"
    config.assets.enabled = false
    config.assets.precompile = []
    config.action_dispatch.cookies_serializer = :json
    config.filter_parameters += [:password]
  end
end
