class User
  class CrawlDataJob < ApplicationJob
    include NoRetryJob

    queue_as :low

    def perform(user)
      return if user.crawl_data

      user.errors[:base].each do |error_message|
        ErrorNotifier.capture_info(error_message, user: { id: user.id, username: user.username })
      end
    end
  end
end
