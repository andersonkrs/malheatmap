class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :low

  # Make sure we don't enqueue synching unecessarily
  uniqueness_control key: ->(user) { "#{user.id}:#{user.mal_synced_at&.to_fs(:number)}" }, expires_in: 12.hours

  discard_on ActiveRecord::RecordNotFound do |_job, exception|
    Rails.logger.error(exception)
  end

  discard_on MAL::Errors::ProfileNotFound, MAL::Errors::UnableToNavigateToHistoryPage do |job, _error|
    user, = job.arguments

    # When a profile is not found we assume it is an account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    user.schedule_deactivation if user.legacy_account?
  end

  retry_on MAL::Errors::CommunicationError, wait: 1.hour, attempts: 3 do |_job, exception|
    Rails.logger.error(exception)
  end


  def perform(user)
    return unless user.eligible_for_mal_sync?

    user.crawler_pipeline.execute!
  end
end
