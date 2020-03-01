class UserUpdateJob < ApplicationJob
  queue_as :low

  def perform(username)
    logger.info "Updating data for user: #{username}"

    response = UpdateService.call(username)

    logger.info "Response: #{response}"
  end
end
