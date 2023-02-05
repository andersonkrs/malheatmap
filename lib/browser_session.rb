class BrowserSession < ActiveSupport::CurrentAttributes
  attr_accessor :current

  RETRYABLE_ERRORS = [Ferrum::TimeoutError, Ferrum::ProcessTimeoutError, NoMethodError].freeze

  # Reuses the same browser that is on the thread instead of spawning a browser process each time
  # Ideally the browser process is spawned once by the threads manager process like Rails/Sidekiq and then it is
  # reused everytime just create new tabs
  #
  # If there's no browser assigned to the thread a new browser process will be spawned and terminated after
  # performing the given block work on the func #fetch_page

  def self.fetch_page(&)
    if current.present? && current.default_context.present?
      with_new_page(&)
    else
      temp_browser = new_browser
      begin
        yield(temp_browser.page)
      ensure
        temp_browser.quit
      end
    end
  end

  def self.new_browser
    Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
      Ferrum::Browser
        .new(
          headless: !ENV["HEADLESS"].in?(%w[n 0 no false]),
          browser_options: {
            "no-sandbox": nil,
            "disable-setuid-sandbox": nil
          },
          timeout: 30,
          process_timeout: 30
        )
        .tap { |browser| Rails.logger.info "Browser instance created PID: #{browser.process.pid}" }
    end
  end

  def self.with_new_page
    Ferrum::Utils::Attempt.with_retry(errors: RETRYABLE_ERRORS, max: 3, wait: 3.seconds) do
      page = current.create_page
      begin
        yield(page)
      ensure
        page.close
      end
    end
  end
end
