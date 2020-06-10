require "mechanize"

module MAL
  class UserCrawler < Mechanize
    include URLS

    def initialize(username)
      super()
      @username = username
      @response = { profile: {}, history: [] }

      setup_crawler_options
    end

    def crawl
      crawl_profile
      crawl_history

      @response
    rescue Mechanize::ResponseCodeError => error
      handle_response_code_error(error.response_code, error.message)
    end

    private

    def setup_crawler_options
      config = Rails.configuration.crawler

      self.history_added = proc { sleep config[:requests_interval] }
      self.open_timeout = config[:timeout]
      self.read_timeout = open_timeout
    end

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
      exception = custom_exceptions[response_code] || Errors::CrawlError

      raise exception.new(message, username: @username)
    end
  end
end
