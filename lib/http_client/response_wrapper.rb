class HttpClient
  class ResponseWrapper
    def initialize(response:)
      @response = response
    end

    def success?
      @response.is_a?(Net::HTTPSuccess)
    end

    def failure?
      !success?
    end

    def raw_body
      @response.body
    end

    def data
      @data ||= ActiveSupport::JSON.decode(@response.body)
    end
  end
end
