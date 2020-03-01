class UsersUpdateSchedulerJob < ApplicationJob
  queue_as :low

  private

  def perform
    users = User.select(:username).order(:updated_at).all

    users.each do |user|
      UserUpdateJob.perform_later(user.username)
    end
  end
end
