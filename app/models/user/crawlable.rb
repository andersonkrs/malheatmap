class User
  module Crawlable
    extend ActiveSupport::Concern

    included do
      define_callbacks :crawl
    end

    def crawl_mal_data
      run_callbacks(:crawl) do
        user_data = crawler.crawl

        CrawledDataProcessor.new(self, user_data).run
      end

      true
    rescue MAL::Errors::CrawlError => error
      errors.add(:base, error.message)
      false
    end

    def crawl_mal_data_later(wait: 5.seconds)
      CrawlDataJob.set(wait: wait).perform_later(self)
    end

    private

    def crawler
      @crawler ||= MAL::UserCrawler.new(username)
    end
  end
end
