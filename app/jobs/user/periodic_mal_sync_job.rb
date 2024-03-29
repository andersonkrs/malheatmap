class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :low

  discard_on ActiveRecord::RecordNotFound do |_job, exception|
    Rails.logger.error(exception)
  end

  discard_on MAL::Errors::ProfileNotFound, MAL::Errors::UnableToNavigateToHistoryPage do |job, _error|
    user, = job.arguments

    # When a profile is not found we assume it is an account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    user.schedule_deactivation if user.legacy_account?
  end

  retry_on MAL::Errors::CommunicationError, wait: 1.minute, attempts: 3 do |_job, exception|
    Rails.logger.error(exception)
  end

  def perform(user)
    unless user.eligible_for_mal_sync?
      Rails.logger.info("User #{user.username} is not eligible for sync: #{user.mal_synced_at}")
      return
    end

    user.crawler_pipeline.execute!
  end
end
