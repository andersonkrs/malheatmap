require "mechanize"

module MAL
  class UserCrawler < Mechanize
    include URLS

    class_attribute :requests_interval, default: 0

    def initialize(username)
      super()
      @username = username
      @response = { profile: {}, history: [] }

      self.history_added = proc { sleep self.class.requests_interval }
      self.open_timeout = 25.seconds
      self.read_timeout = open_timeout
    end

    def self.crawl(username)
      new(username).crawl_data
    end

    def crawl_data
      crawl_profile
      crawl_history

      @response
    rescue Mechanize::ResponseCodeError => error
      handle_response_code_error(error.response_code, error.message)
    end

    private

    def crawl_profile
      get profile_url(@username)

      @response[:profile] = Parsers::Profile.new(page).parse
    end

    def crawl_history
      page.link_with(text: "History").click

      fetch_history(:anime)
      fetch_history(:manga)
    end

    def fetch_history(kind)
      page.link_with(text: "#{kind.capitalize} History").click

      page.xpath("//tr[td[@class='borderClass']]").each do |row|
        entry = Parsers::Entry.new(row).parse
        entry[:item_kind] = kind

        @response[:history] << entry
      end
    end

    def handle_response_code_error(response_code, message)
      custom_exceptions = {
        "404" => Errors::ProfileNotFound
      }

      raise custom_exceptions[response_code] || Errors::CrawlError, message
    end
  end
end
