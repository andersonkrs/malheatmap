class IncrementalVacuumJob < ApplicationJob
  queue_as :within_20_hours

  PAGES_PER_RUN = 1000

  def perform
    [ ApplicationRecord, OpsRecord, SolidQueue::Record ].each do |base|
      base.connection.execute("PRAGMA incremental_vacuum(#{PAGES_PER_RUN})")
    end
  end
end
