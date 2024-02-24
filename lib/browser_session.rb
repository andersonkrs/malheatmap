class BrowserSession
  RETRYABLE_ERRORS = [
    Ferrum::TimeoutError,
    Ferrum::ProcessTimeoutError,
    Ferrum::PendingConnectionsError,
    Ferrum::JavaScriptError,
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
      Rails.logger.info "Quitting browser process #{browser.process.pid}"
      browser.quit
    end
  end

  def with_new_page
    spawn_new_browser

    Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
      page = browser.create_page
      begin
        yield(page)
      ensure
        page.close
      end
    end
  end

  private

  attr_reader :browser

  def spawn_new_browser
    @browser =
      Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
        Ferrum::Browser
          .new(headless: "new", browser_options: { "no-sandbox": nil, "disable-setuid-sandbox": nil })
          .tap do |browser|
            Rails.logger.info "Browser instance created PID: #{browser.process.pid}"
          end
      end
  end
end
