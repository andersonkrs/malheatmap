class User
  class CrawlDataJob < ApplicationJob
    include NoRetryJob

    queue_as :low

    def perform(user)
      ErrorNotifier.capture_info(user.errors.base, user: { id: user.id, email: user.email }) unless user.crawl_data
    end
  end
end
