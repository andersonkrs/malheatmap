class BrowserSession
  RETRYABLE_ERRORS = [
    Ferrum::DeadBrowserError,
    Ferrum::TimeoutError,
    Ferrum::ProcessTimeoutError,
    Ferrum::PendingConnectionsError,
    Ferrum::JavaScriptError,
    Errno::ECONNREFUSED,
    NoMethodError
  ].freeze

  def self.fetch_page(&)
    instance = new
    instance.with_new_page(&)
  ensure
    instance.quit
  end

  def quit
    if browser
      Rails.logger.info "Quitting browser process #{browser&.process&.pid}"
      browser.reset
      browser.quit
    end
 end

  def with_new_page
    spawn_new_browser

    browser.create_page do
      yield(_1)
    end
  end

  private

  attr_reader :browser

  def spawn_new_browser
    @browser = Ferrum::Browser
      .new({ headless: true, url: ENV["FERRUM_BROWSER_URL"].presence })
      .tap do |browser|
        Rails.logger.info "Browser instance created PID: #{browser.process.pid}"
      end
  end
end
