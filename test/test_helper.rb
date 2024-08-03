ENV["RAILS_ENV"] ||= "test"
ENV["COVERAGE"] ||= "true"

require "simplecov"

if ENV["COVERAGE"] == "true"
  SimpleCov.use_merging true
  SimpleCov.command_name("Minitest")
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

    parallelize(workers: 4)

    parallelize_setup do |worker|
      ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{worker}"

      SimpleCov.command_name "Minitest:#{worker}" if ENV["COVERAGE"] == "true"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result if ENV["COVERAGE"] == "true"
    end

    setup do
      Kernel.silence_warnings { Rails.application.load_tasks }
    end

    teardown do
      Rake::Task.clear
      Rails.cache.clear

      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end

    def render(...)
      ApplicationController.renderer.render(...)
    end
  end
end
