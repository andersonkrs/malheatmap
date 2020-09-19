class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    def perform(user)
      Rails.logger.info("Updating data for user: #{user.username}")

      result = User::UpdateData.call(user: user)

      { success: result.success?, message: result.message }
    end
  end
end
