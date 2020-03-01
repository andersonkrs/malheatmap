ENV["COVERAGE"] = "false"

require "test_helper"
require "webdrivers"
require "capybara"

Webdrivers::Chromedriver.update
Capybara.default_max_wait_time = 20

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
