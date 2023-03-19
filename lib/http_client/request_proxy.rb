class HttpClient
  class RequestProxy
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :site, :immutable_string
    attribute :http_verb, :immutable_string
    attribute :path, :immutable_string
    attribute :request_format, :immutable_string
    attribute :response_format, :immutable_string
    attribute :headers, default: {}
    attribute :body, default: {}
    attribute :query_params, default: {}
    attribute :logger, default: Logger.new(IO::NULL)
    attribute :wrapper
    attribute :actions, default: []

    validates :site, presence: true
    validates :http_verb, presence: true
    validates :path, presence: true
    validates :request_format, presence: true
    validates :response_format, presence: true

    attr_reader :params

    def initialize(...)
      super

      @params = ActiveSupport::HashWithIndifferentAccess.new

      @connection = Net::HTTP::Persistent.new
      connection.idle_timeout = 5
      connection.keep_alive = 300
    end

    def execute(action, ...)
      wrapper.run_callbacks(:action) { wrapper.public_send(action, ...) }

      validate!

      req = new_request_object
      req = set_request_data(req)
      req = set_headers(req)

      logger.debug("Request: #{http_verb} #{req.uri}")

      req.each_header { |header| logger.debug("Request: #{header}") }

      res = connection.request(req.uri, req) { |response| response }

      logger.debug("Response: #{res.code}")
      logger.debug(res.body&.pretty_inspect.to_s)

      ResponseWrapper.new(response: res).tap { wrapper.send(:initialize_proxy) }
    end

    def method_missing(name, ...)
      execute(name, ...) if name.in?(actions)
    end

    def respond_to_missing?(name, ...)
      name.in?(actions)
    end

    private

    attr_reader :connection

    def new_request_object
      uri = build_uri

      case http_verb
      when "post"
        Net::HTTP::Post.new(uri)
      when "get"
        Net::HTTP::Get.new(uri)
      end
    end

    def build_uri
      uri = URI.parse(site)
      uri.path += path
      uri.query = query_params.to_query if http_verb == "get"
      uri
    end

    def set_request_data(request)
      case http_verb
      when "post", "put", "patch"
        set_body(request)
      else
        request
      end
    end

    def set_body(request)
      case request_format
      when "json"
        request.body = body.to_json
        request.set_content_type("application/json")
      when "form_url_encoded"
        request.set_form_data(body.to_hash)
      end

      request
    end

    def set_headers(request)
      headers.each { |key, value| request[key] = value }

      request
    end
  end
end
