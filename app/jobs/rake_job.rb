class RakeJob < ApplicationJob
  limits_concurrency to: 1, key: :unique_jobs, duration: 1.hour
  queue_as :default

  def perform(task)
    Rails.application.load_tasks
    Rake::Task[task].invoke
  end
end
