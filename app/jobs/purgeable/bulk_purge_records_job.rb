module Purgeable
  class BulkPurgeRecordsJob < ApplicationJob
    self.queue_adapter = :sidekiq
    queue_as :default

    retry_on ActiveRecord::StatementInvalid, wait: :polynomially_longer, attempts: 3

    def perform
      CrawlingLogEntry.purge_due(batch_size: 1_000)
    end
  end
end
