module Purgeable
  class PurgeRecordJob < ApplicationJob
    discard_on ActiveRecord::RecordNotFound
    retry_on Purgeable::RecordNotPurgeable, attempts: 20, wait: :exponentially_longer

    def perform(record)
      record.purge!
    end
  end
end
