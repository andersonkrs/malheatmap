class User
  class CrawlData < ApplicationService
    delegate :user, :crawler, to: :context

    before_call do
      context.crawler ||= MAL::UserCrawler.new(user.username)

      Rails.logger.info("Crawling data for user: #{user.username}")
    end

    def call
      context.crawled_data = crawler.crawl
      context.checksum = generate_checksum
    rescue MAL::Errors::CrawlError => error
      context.fail(message: error.message)
    end

    private

    def generate_checksum
      json = Marshal.dump(context.crawled_data)
      OpenSSL::Digest::MD5.hexdigest(json)
    end
  end
end
