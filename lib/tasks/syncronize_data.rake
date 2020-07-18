require_relative "../../config/application"

task syncronize_data: [:environment] do
  logger = Rails.logger
  logger.info "Starting data synchronization..."

  User.order(:updated_at).each do |user|
    logger.info "Updating data for user: #{user.username}"

    User::UpdateData.call!(user: user)
  rescue StandardError => error
    logger.error error
    Rollbar.error(error)
  end
end
