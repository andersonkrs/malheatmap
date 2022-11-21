ENV["COVERAGE"] = "false"

require "test_helper"
require "capybara"
require "capybara/cuprite"

Capybara.default_max_wait_time = 20

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    **{
      window_size: [1200, 800],
      browser_options: {
        "no-sandbox": nil,
        "disable-setuid-sandbox": nil
      },
      timeout: 30,
      process_timeout: 30,
      # Enable debugging capabilities
      inspector: true,
      # Allow running Chrome in a headful mode by setting HEADLESS env
      # var to a falsey value
      headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
    }
  )
end

Capybara.singleton_class.prepend(
  Module.new do
    attr_accessor :last_used_session

    def using_session(name, &block)
      self.last_used_session = name
      super
    ensure
      self.last_used_session = nil
    end
  end
)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite

  private

  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the execution
  def debug(*args)
    page.driver.debug(*args)
  end
end
