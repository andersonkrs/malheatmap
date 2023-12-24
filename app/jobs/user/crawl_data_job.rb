class User
  class CrawlDataJob < ApplicationJob
    include NoRetryJob

    queue_as :low

    discard_on MAL::Errors::ProfileNotFound, MAL::Errors::CommunicationError do |_job, exception|
      Rails.logger.error(exception)
    end

    def perform(user)
      user.crawl_data!
    end
  end
end
