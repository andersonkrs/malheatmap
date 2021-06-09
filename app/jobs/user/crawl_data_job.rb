class User
  class CrawlDataJob < ApplicationJob
    include NoRetryJob

    queue_as :low

    def perform(user)
      result = user.crawl_data

      Rails.logger.warn(user.errors[:base]) unless result
    end
  end
end
