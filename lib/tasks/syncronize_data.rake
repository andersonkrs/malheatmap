require_relative "../../config/application"

task syncronize_data: [:environment] do
  logger = Rails.logger
  logger.info "Starting data syncronization..."

  users = User.select(:username).order(:updated_at)

  users.each do |user|
    logger.info "Updating data for user: #{user.username}"

    UserData::Update.call!(user: user)
  rescue StandardError => error
    logger.error error
  end
end
