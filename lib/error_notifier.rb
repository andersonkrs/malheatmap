class ErrorNotifier
  def self.capture(error)
    Rails.logger.error(error)
    Rollbar.error(error)
  end

  def capture_info(message, **extras)
    Rails.logger.info(message)
    Rollbar.info(message, **extras)
  end
end
