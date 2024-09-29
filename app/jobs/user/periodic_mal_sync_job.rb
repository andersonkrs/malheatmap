class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :low

  uniqueness_control key: -> { _1.id }, expires_in: 48.hours

  discard_on ActiveRecord::RecordNotFound do |_job, exception|
    Rails.logger.error(exception)
  end

  discard_on MAL::Errors::ProfileNotFound, MAL::Errors::UnableToNavigateToHistoryPage do |job, error|
    user, = job.arguments

    # When a profile is not found we assume it is an account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    if user.legacy_account?
      user.schedule_deactivation(reason: error.message)
      Rails.logger.warn("Scheduled deactivation for user #{user.to_global_id}, reason: #{error}")
    else
      Rails.logger.error(error)
      user.touch(:mal_synced_at)
    end
  end

  rescue_from MAL::Errors::CommunicationError do |exception|
    Rails.error.report(exception)
    retry_job(wait: 5.minutes)
  end

  def perform(user)
    unless user.eligible_for_mal_sync?
      Rails.logger.info("User #{user.username} is not eligible for sync: #{user.mal_synced_at}")
      return
    end

    user.crawler_pipeline.execute!
  end
end
