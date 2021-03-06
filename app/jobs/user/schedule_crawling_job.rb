class User
  class ScheduleCrawlingJob < ApplicationJob
    queue_as :default

    def perform
      User.find_each(batch_size: 50, &:crawl_data_later)
    end
  end
end
