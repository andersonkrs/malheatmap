class NotifyError < ApplicationService
  delegate :error, to: :context

  def call
    Rails.logger.error(error)
    Rollbar.error(error, **context_data)
  end

  private

  def context_data
    error.try(:context).to_h
  end
end
