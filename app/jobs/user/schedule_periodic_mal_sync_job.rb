class User::SchedulePeriodicMALSyncJob < ApplicationJob
  queue_as :default

  def perform
    User.eligible_for_mal_sync.find_each { |user| User::PeriodicMALSyncJob.perform_later(user) }
  end
end
