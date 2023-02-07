module MAL
  module Parsers
    class Profile
      include Helpers

      def initialize(page)
        @page = page
      end

      def parse
        { location: location, avatar_url: }
      end

      private

      def location
        @page.at_xpath("//span[contains(@class, 'user-status-title') and text()='Location']/following::span")&.text
      end

      def avatar_url
        @page.at_xpath("//div[contains(@class, 'user-image')]/img/@data-src")&.text
      end
    end
  end
end
