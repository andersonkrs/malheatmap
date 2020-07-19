class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    def perform(user)
      User::UpdateData.call!(user: user)
    end
  end
end
