class ErrorNotifier
  def self.notify(error)
    Rails.logger.error(error)
    Rollbar.error(error)
  end
end
