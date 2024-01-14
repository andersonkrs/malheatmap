class BrowserSession
  include Singleton

  attr_reader :browser
  attr_reader :logger

  def initialize
    super
    @logger = ActiveSupport::TaggedLogging.new(Rails.logger)
    @mutex = Mutex.new
  end

  RETRYABLE_ERRORS = [Ferrum::TimeoutError, Ferrum::ProcessTimeoutError, NoMethodError].freeze

  # Reuses the same browser that is on the thread instead of spawning a browser process each time
  # Ideally the browser process is spawned once and reused during the thread session
  #
  # If there's no browser assigned to the thread a new browser process will be spawned and terminated after
  # performing the given block work on the func #fetch_page
  def fetch_page(&)
    mutex.synchronize do
      spawn_new_browser unless browser.present? && browser.default_context.present?
    end

    with_new_page(&)
  end

  def quit
    if browser
      logger.info "Quitting browser process #{browser.process.pid}"
      browser.quit
    end
  end

  private

  attr_reader :mutex

  def spawn_new_browser
    @browser =
      Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
        Ferrum::Browser
          .new(headless: "new", browser_options: { "no-sandbox": nil, "disable-setuid-sandbox": nil })
          .tap do |browser|
            logger.info "Browser instance created PID: #{browser.process.pid}"
          end
      end
  end

  def with_new_page
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

at_exit do
  BrowserSession.instance&.quit
end
