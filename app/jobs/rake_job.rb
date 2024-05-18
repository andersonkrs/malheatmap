class RakeJob < ApplicationJob
  limits_concurrency to: 1, key: :unique_jobs, duration: 1.hour
  queue_as :default

  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform(task)
    Rails.logger.info "Loading tasks..."
    Rails.application.load_tasks

    Rails.logger.info "Executing task: #{task}"
    Rake::Task[task].execute
  end
end
