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
        capture_failure_log_entry(error: error, raw_data: raw_data)
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
        create_log_entry(failure: true, failure_message: error.message, raw_data: raw_data)
      end

      def create_log_entry(raw_data:, failure: false, failure_message: nil)
        user.crawling_log_entries.create!(raw_data: raw_data,
                                          failure: failure,
                                          failure_message: failure_message) do |log|
          log.calculate_checksum
          attach_visited_pages(log)
        end
      end

      def attach_visited_pages(log)
        crawler.history.each do |page|
          log.visited_pages.attach(
            io: StringIO.new(page.body),
            filename: "#{page.uri.path.split('/').last}.html",
            content_type: "text/html"
          )
        end
      end
    end
  end
end
