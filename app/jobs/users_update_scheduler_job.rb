class UsersUpdateSchedulerJob < ApplicationJob
  queue_as :default

  private

  def perform
    users = User.select(:username).where("updated_at > ?", 12.hours.ago).all

    users.each do |user|
      UserUpdateJob.perform_later(user.username)
    end
  end
end
