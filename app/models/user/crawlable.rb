class User
  module Crawlable
    extend ActiveSupport::Concern

    def crawled_data
      @crawled_data ||= CrawledData.new(self)
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
