class BrowserSession < ActiveSupport::CurrentAttributes
  attribute :browser

  RETRYABLE_ERRORS = [Ferrum::TimeoutError, Ferrum::ProcessTimeoutError, NoMethodError].freeze

  before_reset { browser&.quit }

  # Reuses the same browser that is on the thread instead of spawning a browser process each time
  # Ideally the browser process is spawned once and reused during the thread session
  #
  # If there's no browser assigned to the thread a new browser process will be spawned and terminated after
  # performing the given block work on the func #fetch_page

  def self.fetch_page(&)
    spawn_new_browser unless browser.present? && browser.default_context.present?

    with_new_page(&)
  end

  def self.spawn_new_browser
    self.browser =
      Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
        Ferrum::Browser
          .new(headless: "new", browser_options: { "no-sandbox": nil, "disable-setuid-sandbox": nil })
          .tap { |browser| Rails.logger.info "Browser instance created PID: #{browser.process.pid}" }
      end
  end

  def self.with_new_page
    Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
      page = browser.create_page
      begin
        yield(page)
      ensure
        page.close
      end
    end
  end
end
