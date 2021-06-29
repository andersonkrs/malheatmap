class User
  module Crawlable
    extend ActiveSupport::Concern

    included do
      has_many :crawling_log_entries, -> { order(created_at: :desc) },
               class_name: "User::Crawlable::CrawlingLogEntry",
               inverse_of: :user, foreign_key: "user_id",
               dependent: :destroy
    end

    def crawl_data
      pipeline = CrawlerPipeline.new(self)
      pipeline.execute

      true
    rescue MAL::Errors::CrawlError => error
      errors.add(:base, error.message)
      false
    end

    def crawl_data_later(wait: 5.seconds)
      CrawlDataJob.set(wait: wait).perform_later(self)
    end

    private

    def crawler
      @crawler ||= MAL::UserCrawler.new(username)
    end
  end
end
