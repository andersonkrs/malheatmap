ENV["RAILS_ENV"] ||= "test"
ENV["COVERAGE"] ||= "true"

require "simplecov"
require "simplecov-cobertura"

if ENV["COVERAGE"] == "true"
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ]

  SimpleCov.use_merging true
  SimpleCov.minimum_coverage 95
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
require "factory_bot_rails"

Rails.application.load_tasks

Dir["./test/support/**/*.rb"].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper
    include ActionCable::TestHelper
    include FactoryBot::Syntax::Methods
    include MechanizeTestHelper

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
      VCR.insert_cassette [class_name.underscore, name].join("/")
    end

    teardown do
      VCR.eject_cassette
    end
  end
end

Minitest.after_run do
  FileUtils.rm_rf(Rails.root.join("tmp/storage"))
end
