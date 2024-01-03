class User
  module MALSyncable
    extend ActiveSupport::Concern

    INTERVAL_BETWEEN_SYNCS = 8.hours

    included do
      has_many :crawling_log_entries, inverse_of: :user, dependent: :destroy

      scope :eligible_for_mal_sync,
            -> do
              active
                .where(mal_synced_at: nil)
                .or(active.where(mal_synced_at: (...INTERVAL_BETWEEN_SYNCS.ago)))
                .order(arel_table[:mal_synced_at].asc.nulls_first)
            end

      after_authentication :enqueue_immediate_sync, if: :never_synced_mal?
    end

    def crawler_pipeline
      CrawlerPipeline.new(self)
    end

    def never_synced_mal?
      mal_synced_at.blank?
    end

    def eligible_for_mal_sync?
      return false if deactivated?

      saved_change_to_mal_id? || mal_synced_at.blank? || mal_synced_at.before?(INTERVAL_BETWEEN_SYNCS.ago)
    end

    def enqueue_immediate_sync
      User::PeriodicMALSyncJob.set(queue: :default).perform_later(self)
    end
  end
end
