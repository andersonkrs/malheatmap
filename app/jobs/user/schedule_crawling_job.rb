class User
  class ScheduleCrawlingJob < ApplicationJob
    queue_as :default

    def perform(batch_size: 100, batch_interval: 15.minutes)
      User.in_batches(of: batch_size).each_with_index do |batch, batch_index|
        interval = batch_interval * (batch_index + 1)

        batch.each do |user|
          user.crawl_data_later(wait: interval)
        end
      end
    end
  end
end
