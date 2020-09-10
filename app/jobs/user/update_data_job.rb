class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    def perform(user)
      logger.info("Updating data for user: #{user.username}")

      result = User::UpdateData.call(user: user)
      logger.error(result.message) if result.failure?
    end

    private

    def logger
      Rails.logger
    end
  end
end
