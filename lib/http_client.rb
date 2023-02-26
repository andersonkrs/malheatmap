# frozen_string_literal: true
class HttpClient
  class RequestWrapper
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

    validates :site, presence: true
    validates :http_verb, presence: true
    validates :path, presence: true
    validates :request_format, presence: true
    validates :response_format, presence: true

    def initialize(...)
      super

      @connection = Net::HTTP::Persistent.new
      connection.idle_timeout = 5
      connection.keep_alive = 300
    end

    def execute
      validate!

      req = new_request_object
      req = set_request_data(req)
      req = set_headers(req)

      logger.debug("Request: #{http_verb} #{req.uri}")

      req.each_header do |header|
        logger.debug("Request: #{header}")
      end

      res = connection.request(req.uri, req) { |res|
        res
      }

      logger.debug("Response: #{res.code}")
      logger.debug("#{res.body&.pretty_inspect}")

      ResponseWrapper.new(response: res)
    end

    private

    attr_reader :connection

    def new_request_object
      uri = build_uri()

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
        request.set_content_type('application/json')
      when "form_url_encoded"
        request.set_form_data(body.to_hash)
      end

      request
    end

    def set_headers(request)
      headers.each do |key, value|
        request[key] = value
      end

      request
    end
  end

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

    def data
      @data ||= ActiveSupport::JSON.decode(@response.body)
    end
  end
end

class HttpClient
  class_attribute :_site
  class_attribute :_request_format, default: :json
  class_attribute :_response_format, default: :json
  class_attribute :_logger

  def self.site(uri)
    self._site = URI.parse(uri)
  end

  def self.logger(value)
    self._logger = value
  end

  def self.request_format(value)
    self._request_format = value
  end

  def self.response_format(value)
    self._request_format = value
  end

  def self.with(**args)
    self.new.with(**args)
  end

  def self.method_missing(name, ...)
    if name.in?(public_instance_methods(false))
      self.new.send(name, ...)
    end
  end

  def initialize
    super

    @params = ActiveSupport::HashWithIndifferentAccess.new

    initialize_request
  end

  def with(**args)
    @params.merge!(**args)
    self
  end

  private

  attr_reader :request
  attr_reader :params

  def header(values)
    request.headers.merge!(values)
  end

  def site(value)
    request.site = value.to_s.ends_with?("/") ? value : URI.parse("#{value}/")
  end

  def logger(value)
    request.logger = value
  end

  def request_format(value)
    request.request_format = value
  end

  def response_format(value)
    request.response_format = value
  end

  def post(path, body:)
    request.http_verb = :post
    request.path = path
    request.body = body
    execute
  end

  def get(path, query_params: {})
    request.http_verb = :get
    request.path = path
    request.query_params = query_params
    execute
  end

  def execute
    response = request.execute

    initialize_request

    response
  end

  def initialize_request
    @request = RequestWrapper.new

    site self._site
    request_format self._request_format
    response_format self._response_format
    logger self._logger
  end
end
