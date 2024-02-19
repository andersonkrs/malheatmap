module Purgeable
  class BulkPurgeRecordsJob < ApplicationJob
    queue_as :default

    def perform
      CrawlingLogEntry.purge_due(batch_size: 1_000)
    end
  end
end
