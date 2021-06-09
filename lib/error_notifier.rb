class ErrorNotifier
  def self.capture(error)
    Rails.logger.error(error)
    Rollbar.error(error)
  end
end
