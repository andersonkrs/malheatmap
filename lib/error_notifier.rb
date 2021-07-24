class ErrorNotifier
  def self.capture(error, **extras)
    Rails.logger.error(error)
    Rollbar.error(error, **extras)
  end
end
