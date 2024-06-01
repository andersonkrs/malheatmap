class RakeJob < ApplicationJob
  limits_concurrency to: 1, key: :unique_jobs, duration: 1.hour
  queue_as :default

  def perform(task, env = {})
    Rails.logger.info "Loading tasks..."
    Rails.application.load_tasks

    Rails.logger.info "Executing task: #{task}, env: #{env}"
    env.each do |key, value|
      ENV[key.to_s] = value
    end
    Rake::Task[task].execute
  end
end
