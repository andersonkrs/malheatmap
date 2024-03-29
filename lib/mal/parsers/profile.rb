module MAL
  module Parsers
    class Profile
      include Helpers

      def initialize(page)
        @page = page
      end

      def parse
        { location: clean_text(location), avatar_url: }
      end

      private

      def location
        @page.at_xpath(
          "//span[contains(@class, 'user-status-title') and text()='Location']/following::span/text()"
        ).to_s
      end

      def avatar_url
        @page.at_xpath("//div[contains(@class, 'user-image')]/img/@data-src").to_s
      end
    end
  end
end
