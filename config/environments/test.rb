# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false

  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  config.consider_all_requests_local = true

  config.action_dispatch.show_exceptions = false

  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  config.active_job.queue_adapter = :test
  config.active_storage.service = :local

  config.log_level = :debug
end
