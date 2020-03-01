ENV["COVERAGE"] = "false"

require "test_helper"
require "webdrivers"

Webdrivers::Chromedriver.update

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
