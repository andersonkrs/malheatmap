class User
  module MALSyncable
    class CrawlerPipeline
      def initialize(user)
        super()
        @user = user
      end

      def execute!
        @raw_data = crawler.crawl

        process_success_crawling!
      rescue StandardError => error
        capture_failure!(error)
        raise
      end

      def execute_later(**)
        User::CrawlerPipelineJob.set(**).perform_later(user)
      end

      private

      attr_reader :user, :raw_data

      def crawler
        @crawler ||= MAL::UserCrawler.new(user.username)
      end

      def process_success_crawling!
        user.crawling_log_entries.create!(raw_data:, visited_pages:)
      end

      def capture_failure!(error)
        user.crawling_log_entries.capture_failure!(exception: error, raw_data:, visited_pages:)
      end

      def visited_pages
        crawler.history.map { |page| { body: page.body.force_encoding("UTF-8"), path: page.uri.path } }
      end
    end
  end
end
