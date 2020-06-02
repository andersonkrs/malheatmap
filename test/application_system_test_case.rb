ENV["COVERAGE"] = "false"

require "test_helper"
require "webdrivers"
require "capybara"

Capybara.default_max_wait_time = 20

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless no-sandbox window-size=1920,1080]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome,
                                      options: options,
                                      desired_capabilities: {
                                        "goog:loggingPrefs" => { browser: "ALL" }
                                      })
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :headless_chrome

  def before_teardown
    super
    flush_browser_logs
  end

  private

  def flush_browser_logs
    page.driver.browser.manage.logs.get("browser").each do |entry|
      Rails.logger.info "[Browser] #{entry}"
    end
  end
end
