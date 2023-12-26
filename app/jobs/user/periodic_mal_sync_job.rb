class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :low

  uniqueness_control key: ->(user) { "#{user.id}:#{user.mal_synced_at&.to_fs(:number)}" },
                     expires_in: User::MALSyncable::INTERVAL_BETWEEN_SYNCS

  discard_on ActiveRecord::RecordNotFound do |_job, exception|
    Rails.logger.error(exception)
  end

  retry_on MAL::Errors::CommunicationError, wait: :polynomially_longer, attempts: 3

  retry_on MAL::Errors::ProfileNotFound,
           MAL::Errors::UnableToNavigateToHistoryPage,
           wait: :polynomially_longer,
           attempts: 3 do |job, _error|
    user, = job.arguments

    # When a profile is not found we assume it is a legacy account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    user.schedule_deactivation if user.legacy_account?
  end

  def perform(user)
    return unless user.eligible_for_mal_sync?

    user.crawler_pipeline.execute!
  end
end
