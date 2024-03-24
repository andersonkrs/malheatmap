class User::PeriodicMALSyncJob < ApplicationJob
  queue_as :low

  discard_on ActiveRecord::RecordNotFound do |_job, exception|
    Rails.logger.error(exception)
  end

  retry_on MAL::Errors::CommunicationError, wait: :polynomially_longer, attempts: 3 do |_job, exception|
    Rails.logger.error(exception)
  end

  retry_on MAL::Errors::ProfileNotFound,
           MAL::Errors::UnableToNavigateToHistoryPage,
           wait: :polynomially_longer,
           attempts: 3 do |job, _error|
    user, = job.arguments

    # When a profile is not found we assume it is a account that has no linkage anymore
    # So we deactivate this profile to avoid keep crawling it with no purpose
    user.schedule_deactivation if user.legacy_account?
  end

  def perform(user)
    return unless user.eligible_for_mal_sync?

    user.crawler_pipeline.execute!
  end
end
