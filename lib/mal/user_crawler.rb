require "mechanize"

module MAL
  class UserCrawler < Mechanize
    include URLS

    INTERNAL_COMMUNICATION_ERRORS = [
      Mechanize::ResponseReadError,
      Mechanize::RedirectLimitReachedError,
      Net::ReadTimeout,
      Net::OpenTimeout,
      OpenSSL::SSL::SSLError,
      Errno::ECONNRESET,
      SocketError
    ].freeze

    def initialize(username)
      super
      @username = username
      @response = { profile: {}, history: [] }

      setup_crawler_options
    end

    def crawl
      crawl_profile
      crawl_geolocation
      crawl_history


      response
    rescue Mechanize::ResponseCodeError => error
      handle_response_code_error(error.response_code.to_i, error.message)
    rescue *INTERNAL_COMMUNICATION_ERRORS => e
      raise Errors::CommunicationError, username: username
    end

    private

    attr_reader :username, :response

    def setup_crawler_options
      config = Rails.configuration.crawler

      self.user_agent_alias = Mechanize::AGENT_ALIASES.keys.sample
      self.history_added = proc { sleep config[:requests_interval] }
      self.open_timeout = config[:timeout]
      self.read_timeout = config[:timeout]
      self.log = Rails.logger
    end

    def crawl_profile
      get(profile_url(username))

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
      history_link = page.link_with(text: /History/)
      return if history_link.blank?

      history_link.click

      if (kind_link = page.link_with(text: /Anime History/))
        kind_link.click

        response[:history] += Parsers::History.new(page, kind: :anime).parse if public_history?
      end

      if (kind_link = page.link_with(text: /Manga History/))
        kind_link.click

        response[:history] += Parsers::History.new(page, kind: :manga).parse if public_history?
      end
    end

    def time_zone_for(lat, long)
      results = [WhereTZ.lookup(lat, long)].flatten.compact
      results.first
    rescue ArgumentError
      "UTC"
    end

    def public_history?
      page.xpath("//*[contains(text(),'Access to this list history has been restricted by the owner')]").blank?
    end

    def raise_private_history
      raise Errors::UnableToNavigateToHistoryPage.new(body: page.body, uri: page.uri)
    end

    def handle_response_code_error(response_code, message)
      exception_class = (response_code == 404 ? Errors::ProfileNotFound : Errors::CommunicationError)

      raise exception_class.new(message, username:, response_code:)
    end
  end
end
