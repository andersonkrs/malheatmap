class User
  module Crawlable
    extend ActiveSupport::Concern

    included do
      has_many :crawling_log_entries,
               class_name: "User::Crawlable::CrawlingLogEntry",
               inverse_of: :user,
               foreign_key: "user_id",
               dependent: :destroy
    end

    def crawl_data(*)
      crawl_data!(*)

      true
    rescue MAL::Errors::CrawlError => error
      errors.add(:base, error.message)
      false
    end

    def crawl_data!(update_profile: true)
      pipeline = CrawlerPipeline.new(self, update_profile:)
      pipeline.execute
    end

    def crawl_data_later(wait: 5.seconds)
      CrawlDataJob.set(wait:).perform_later(self)
    end
  end
end
