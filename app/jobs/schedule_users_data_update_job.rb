class ScheduleUsersDataUpdateJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Updating users data"

    users = users_have_not_been_updated(at_least: 4.hours)
    users.each do |user|
      User::UpdateDataJob.perform_later(user)
    end
  end

  private

  def users_have_not_been_updated(at_least:)
    User
      .where(User.arel_table[:updated_at].lteq(at_least.ago))
      .order(:updated_at)
      .limit(100)
      .select(:id)
      .shuffle
  end
end
