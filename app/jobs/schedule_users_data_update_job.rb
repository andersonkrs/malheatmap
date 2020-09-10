class ScheduleUsersDataUpdateJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Updating users data"

    User.order(:updated_at).each do |user|
      User::UpdateDataJob.set(wait: 5.seconds).perform_later(user)
    end
  end
end
