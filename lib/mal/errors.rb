module MAL
  module Errors
    class CrawlError < StandardError
      def reference
        self.class.to_s.demodulize.underscore
      end
    end

    class ProfileNotFound < CrawlError; end
  end
end
