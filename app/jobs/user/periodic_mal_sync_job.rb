class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :within_20_hours

  limits_concurrency to: 1, key: ->(user) { user.id }, on_conflict: :discard, duration: 15.days

  retry_on MAL::Errors::ProfileNotFound, MAL::Errors::UnableToNavigateToHistoryPage, attempts: 15, wait: :polynomially_longer do |job, error|
    Rails.error.report(error)
    user, = job.arguments

    # When a profile is not found we assume it is an account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    user.schedule_deactivation(reason: error.message)
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
