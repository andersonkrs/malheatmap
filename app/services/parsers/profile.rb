module Parsers
  class Profile
    include CallableService

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def call
      {
        avatar_url: page.at_xpath("//div[contains(@class, 'user-image')]/img/@data-src").to_s
      }
    end
  end
end
