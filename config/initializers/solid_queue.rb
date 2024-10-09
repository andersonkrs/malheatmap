Rails.application.configure do
  config.solid_queue.silence_polling = true
end

require "solid_queue"

module QueueExtensions
  extend ActiveSupport::Concern

  def latency
    now = Time.current
    oldest_job = SolidQueue::ReadyExecution.queued_as(name).minimum(:created_at) || now

    now - oldest_job
  end
end

Rails.configuration.to_prepare do
  SolidQueue::Queue.include(QueueExtensions)
end
