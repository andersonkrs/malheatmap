class CrawlUserData < ApplicationService
  delegate :user, :crawler, to: :context

  before_call do
    context.crawler ||= MAL::UserCrawler.new(user.username)
  end

  def call
    context.crawled_data = crawler.crawl
  rescue MAL::Errors::CrawlError => error
    context.fail(message: error.message)
  end
end
