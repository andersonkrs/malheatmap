class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    def perform(user)
      result = User::UpdateData.call(user: user)

      Rails.logger.warn(result.message) if result.failur
    end
  end
end
