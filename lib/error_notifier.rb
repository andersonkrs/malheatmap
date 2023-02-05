class ErrorNotifier
  def self.capture(error, **extras)
    Rails.logger.error(error)
    Rollbar.error(error, **extras) if Rails.env.production?
  end
end
