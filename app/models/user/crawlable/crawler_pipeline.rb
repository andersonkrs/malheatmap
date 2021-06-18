class User
  module Crawlable
    class CrawlerPipeline
      def initialize(user)
        super()
        @user = user
      end

      def execute
        new_data = crawler.crawl
        user.crawled_data.import(new_data)

        generate_activities
        generate_new_signature_image
      end

      private

      attr_reader :user

      def crawler
        @crawler ||= MAL::UserCrawler.new(user.username)
      end

      def generate_activities
        return unless user.crawled_data.changed?

        user.activities.generate_from_history
      end

      def generate_new_signature_image
        return if !user.crawled_data.changed? && !user.signature_image.obsolete?

        user.signature_image.generate
      end
    end
  end
end
