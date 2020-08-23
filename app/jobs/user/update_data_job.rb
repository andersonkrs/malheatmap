class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    def perform(user)
      Rails.logger.info "Updating data for user: #{user.username}"

      User::UpdateData.call!(user: user)
    end
  end
end
