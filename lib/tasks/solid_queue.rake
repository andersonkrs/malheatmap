namespace :solid_queue do
  desc "Checks whether all workers are online"
  task workers_health_check: [:environment] do
    queues = SolidQueue::Helper.queues_from_config

    queues.each do |queue|
      unless SolidQueue::Helper.active_processes_for_queue?(queue_name: queue)
        puts("Active process for queue #{queue} not found. Exiting 1")
        abort()
      end

      if SolidQueue::Helper.stuck_executions_for_queue?(queue_name: queue, threshold: 30.minutes)
        puts("Stuck executions on queue #{queue}. Exiting 1")
        abort()
      end

      puts("QUEUE UP #{queue}")
    end
  end
end
