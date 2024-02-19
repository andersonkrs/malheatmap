class User::SchedulePeriodicMALSyncJob < ApplicationJob
  queue_as :default

  def perform
    User.eligible_for_mal_sync.find_each do |user|
      Rails.logger.info "Periodic Sync scheduled for: #{user.username}"
      User::PeriodicMALSyncJob.perform_later(user)
    end
  end
end
