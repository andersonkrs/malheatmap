ENV["RAILS_ENV"] ||= "test"
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

    parallelize(workers: 1)

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
