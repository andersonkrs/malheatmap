class User
  module Crawlable
    class CrawlerPipeline
      def initialize(user)
        super()
        @user = user
      end

      def execute
        raw_data = crawler.crawl

        process_raw_data(raw_data)
      rescue StandardError => error
        capture_failure_log_entry(error:, raw_data:)
        raise
      end

      private

      attr_reader :user

      def crawler
        @crawler ||= MAL::UserCrawler.new(user.username)
      end

      def process_raw_data(data)
        crawling_log_entry = create_log_entry(raw_data: data)
        crawling_log_entry.apply_data_changes_to_user

        user.activities.generate_from_history if user.saved_change_to_checksum?
        user.signature_image.generate if user.signature_image.obsolete?
      end

      def capture_failure_log_entry(error:, raw_data:)
        create_log_entry(failure: true, failure_message: error.message, raw_data:)
      end

      def create_log_entry(raw_data:, failure: false, failure_message: nil)
        log_entry = user.crawling_log_entries.build(raw_data:,
                                                    failure:,
                                                    failure_message:,
                                                    visited_pages:)
        log_entry.calculate_checksum
        log_entry.save!
        log_entry
      end

      def visited_pages
        crawler.history.map do |page|
          {
            body: page.body.force_encoding("UTF-8"),
            path: page.uri.path
          }
        end
      end
    end
  end
end
