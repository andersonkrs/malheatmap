require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "#{::Rails.root}/test/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_host "chromedriver.storage.googleapis.com"
end
