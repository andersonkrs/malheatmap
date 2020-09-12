require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "#{::Rails.root}/test/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_host "chromedriver.storage.googleapis.com"
end

module VCRCassettes
  extend ActiveSupport::Concern

  included do
    setup do
      VCR.insert_cassette [class_name.underscore, name].join("/")
    end

    teardown do
      VCR.eject_cassette
    end
  end
end
