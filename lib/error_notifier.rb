class ErrorNotifier
  def self.capture(error, **extras)
    Rails.logger.error(error)
    Honeybadger.notify(error, context: extras)
  end
end
