module MAL
  module Errors
    class CrawlError < StandardError
      def initialize(msg = nil, **params)
        localized_message = I18n.t(
          "mal.crawler.errors.#{self.class.to_s.demodulize.underscore}",
          **params,
          default: msg
        )

        super(localized_message)
      end
    end

    class ProfileNotFound < CrawlError; end
  end
end
