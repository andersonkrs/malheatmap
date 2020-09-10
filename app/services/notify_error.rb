class NotifyError < ApplicationService
  delegate :error, to: :context

  def call
    Rails.logger.error(error)
    Rollbar.error(error)
  end
end
