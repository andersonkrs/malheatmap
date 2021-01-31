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

Dir["./test/support/**/*.rb"].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper
    include ActionCable::TestHelper

    fixtures :all

    parallelize

    if ENV["COVERAGE"] == "true"
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do |_worker|
        SimpleCov.result
      end
    end

    setup do
      Rails.application.load_tasks
    end

    teardown do
      Rake::Task.clear
      Rails.cache.clear
    end
  end
end

Minitest.after_run do
  FileUtils.rm_rf(Rails.root.join("tmp/storage", Rails.env))
end
