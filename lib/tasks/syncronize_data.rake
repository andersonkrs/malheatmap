require_relative "../../config/application"

task syncronize_data: [:environment] do
  logger = Rails.logger
  logger.info "Starting data syncronization..."

  usernames = User.select(:username).order(:updated_at).pluck(:username)

  usernames.each do |username|
    logger.info "Updating data for user: #{username}"

    response = SyncronizationService.syncronize_user_data(username)

    logger.info "Response: #{response}"
  rescue StandardError => error
    logger.error error
  end
end
