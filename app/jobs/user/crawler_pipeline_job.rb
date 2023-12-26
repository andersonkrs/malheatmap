class User::CrawlerPipelineJob < ApplicationJob
  queue_as :default

  retry_on MAL::Errors::CommunicationError, wait: :polynomially_longer, attempts: 3

  discard_on MAL::Errors::ProfileNotFound, MAL::Errors::UnableToNavigateToHistoryPage do |_job, exception|
    Rails.logger.error(exception)
  end

  def perform(user)
    user.crawler_pipeline.execute!
  end
end
