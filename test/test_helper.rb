ENV["RAILS_ENV"] ||= "test"
ENV["COVERAGE"] ||= "true"

require "simplecov"

if ENV["COVERAGE"] == "true"
  SimpleCov.use_merging true
  SimpleCov.start do
    add_filter "config"
    add_filter "vendor"
    add_filter "bin"
    add_filter "db"
    add_filter "test"
  end
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"
require "mocha/minitest"

Dir["./test/support/**/*.rb"].each { |file| require file }

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper
    include ActionCable::TestHelper

    fixtures :all

    parallelize

    if ENV["COVERAGE"] == "true"
      parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }

      parallelize_teardown { |_worker| SimpleCov.result }
    end

    setup do
      Kernel.silence_warnings { Rails.application.load_tasks }
    end

    teardown do
      Rake::Task.clear
      Rails.cache.clear
    end
  end
end

Minitest.after_run { FileUtils.rm_rf Rails.root.join("storage/test") }
