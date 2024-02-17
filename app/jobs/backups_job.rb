class BackupsJob < ApplicationJob
  self.queue_adapter = :sidekiq
  queue_as :default

  def perform
    Rails.application.load_tasks
    Rake::Task["backups:perform"].invoke
  end
end
