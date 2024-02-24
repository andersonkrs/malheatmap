class User::MALSyncable::CrawlerPipeline
  def initialize(user)
    super()
    @user = user
  end

  def execute!
    user.crawling_log_entries.record do |crawler_entry|
      crawler_entry.raw_data = crawler.crawl

      data = User::MALSyncable::ScrapedData.new(user:, raw_data: crawler_entry.raw_data)
      data.process!

      user.mal_synced_at = Time.current
      user.save!

      crawler_entry.checksum = data.checksum
    ensure

      crawler_entry.visited_pages.build(visited_pages)
    end
  end

  def execute_later(**)
    User::CrawlerPipelineJob.set(**).perform_later(user)
  end

  private

  attr_reader :user, :raw_data, :crawler_log_entry

  def crawler
    @crawler ||= MAL::UserCrawler.new(user.username)
  end

  def visited_pages
    crawler.history.map { |page| { body: page.body, url: page.uri.path } }
  end
end
