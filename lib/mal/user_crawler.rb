require "mechanize"

module MAL
  class UserCrawler
    include URLS

    def initialize(username)
      @username = username
      @response = { profile: {}, history: [] }
      @history = []
    end

    def crawl
      BrowserSession.fetch_page do |page|
        @page = page

        crawl_profile
        crawl_geolocation
        crawl_history
      end

      response
    ensure
      @page = nil
    end

    attr_reader :history

    private

    attr_reader :username, :response, :page

    def crawl_profile
      page.goto profile_url(username)
      check_response!

      response[:profile] = Parsers::Profile.new(page).parse
    end

    def crawl_geolocation
      location = @response.dig(:profile, :location)
      return if location.blank?

      result = Geocoder.search(location)
      coordinates = result&.first&.coordinates
      return if coordinates.blank?

      lat, long = *coordinates

      response[:profile].merge!(latitude: lat, longitude: long, time_zone: time_zone_for(lat, long))
    end

    def crawl_history
      crawl_history_kind(:anime)
      crawl_history_kind(:manga)
    end

    def time_zone_for(lat, long)
      results = [WhereTZ.lookup(lat, long)].flatten.compact
      results.first
    rescue ArgumentError
      "UTC"
    end

    def crawl_history_kind(kind)
      page.goto history_url(username, kind)
      check_response!

      response[:history] += Parsers::History.new(page, kind:).parse
    end

    def check_response!
      response_code = page.network.response.status
      case response_code
      when 404
        raise Errors::ProfileNotFound.new(404, message: "Profile not found")
      when (300...)
        raise Errors::CommunicationError.new(404, message: "CommunicationError")
      else
        nil
      end
    end
  end
end
