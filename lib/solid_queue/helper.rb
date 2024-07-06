module SolidQueue::Helper
  extend self

  def queues_from_config
    Rails.application.config_for(:solid_queue).workers.pluck(:queues).flatten
  end

  def stuck_executions_for_queue?(queue_name:, threshold: 3.hours)
    SolidQueue::ClaimedExecution
      .joins(:process, :job)
      .where(solid_queue_processes: { kind: "Worker" })
      .where("solid_queue_claimed_executions.created_at < ?", threshold.ago)
      .where(solid_queue_jobs: { queue_name: queue_name })
      .distinct
      .exists?
  end

  def active_processes_for_queue?(queue_name:)
    SolidQueue::Process
      .where(kind: "Worker")
      .where("last_heartbeat_at >= ?", SolidQueue.process_alive_threshold.ago)
      .any? {
        queue_names = _1.metadata.fetch(:queues, "").split(",")

        queue_name.in?(queue_names)
      }
  end
end
