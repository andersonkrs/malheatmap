require "mechanize"

module MAL
  class UserCrawler < Mechanize
    include URLS
    include Stubbing

    INTERNAL_COMMUNICATION_ERRORS = [
      Mechanize::ResponseReadError,
      Mechanize::RedirectLimitReachedError,
      Net::ReadTimeout,
      Net::OpenTimeout,
      OpenSSL::SSL::SSLError
    ].freeze

    def initialize(username)
      super
      @username = username
      @response = { profile: {}, history: [] }

      setup_crawler_options
    end

    def crawl
      return stubed_response(@username) if stubed?(@username)

      crawl_profile
      crawl_geolocation
      crawl_history

      @response
    rescue Mechanize::ResponseCodeError => error
      handle_response_code_error(error.response_code.to_i, error.message)
    rescue *INTERNAL_COMMUNICATION_ERRORS
      raise Errors::CommunicationError
    end

    private

    def setup_crawler_options
      config = Rails.configuration.crawler

      self.history_added = proc { sleep config[:requests_interval] }
      self.open_timeout = config[:timeout]
      self.read_timeout = config[:timeout]
    end

    def crawl_profile
      get(profile_url(@username))

      @response[:profile] = Parsers::Profile.new(page).parse
    end

    def crawl_geolocation
      location = @response.dig(:profile, :location)
      return if location.blank?

      result = Geocoder.search(location)
      return if result.blank?

      geodata = result.first
      @response[:profile].merge!(
        latitude: geodata.latitude,
        longitude: geodata.longitude,
        time_zone: time_zone_for(*geodata.coordinates)
      )
    end

    def crawl_history
      page.link_with(text: "History").click

      crawl_history_kind(:anime)
      crawl_history_kind(:manga)
    end

    def time_zone_for(lat, long)
      results = [WhereTZ.lookup(lat, long)].flatten.compact
      results.first
    end

    def crawl_history_kind(kind)
      page.link_with(text: "#{kind.capitalize} History").click

      @response[:history] += Parsers::History.new(page, kind: kind).parse
    end

    def handle_response_code_error(response_code, message)
      exception_class = if response_code == 404
                          Errors::ProfileNotFound
                        else
                          Errors::CommunicationError
                        end

      raise exception_class.new(message, username: @username)
    end
  end
end
