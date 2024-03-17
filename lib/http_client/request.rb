module HttpClient
  class Request
    attr_accessor :site, :path, :http_verb, :body, :query_params, :content_type, :headers

    delegate :logger, to: :client

    # @param [HttpClient::Base] client
    def initialize(client:)
      @client = client
      @site = client.site
      @content_type = client.content_type
      @headers = client.default_headers
      @query_params = {}
      super()
    end

    def uri
      uri = site.to_s.ends_with?("/") ? URI.parse(site.to_s) : URI.parse("#{site}/")
      uri.path += path
      uri.query = query_params.to_query if http_verb == "get"
      uri
    end

    def perform
      client.handle_exceptions do
        client.run_callbacks(:request) do
          client.adapter.execute!(self)
        end
      end
    end

    private

    attr_reader :client
  end
end
