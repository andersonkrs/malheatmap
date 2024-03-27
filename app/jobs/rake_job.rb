class RakeJob < ApplicationJob
  queue_as :default

  def perform(task)
    Rails.application.load_tasks
    Rake::Task[task].invoke
  end
end
