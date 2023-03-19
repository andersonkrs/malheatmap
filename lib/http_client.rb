# frozen_string_literal: true

class HttpClient
  extend ActiveModel::Callbacks

  define_model_callbacks :action

  class_attribute :_site
  class_attribute :_request_format, default: :json
  class_attribute :_response_format, default: :json
  class_attribute :_logger, default: Logger.new(IO::NULL)

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
    new.proxy.tap { |proxy| proxy.params.merge!(**args) }
  end

  def self.method_missing(name, ...)
    new.proxy.execute(name, ...) if name.in?(public_instance_methods(false))
  end

  def self.respond_to_missing?(name, ...)
    name.in?(public_instance_methods(false))
  end

  attr_reader :proxy

  def initialize
    super

    initialize_proxy
  end

  delegate :params, to: :proxy

  private

  def header(values)
    proxy.headers.merge!(values)
  end

  def site(value)
    proxy.site = value.to_s.ends_with?("/") ? value : URI.parse("#{value}/")
  end

  def logger(value)
    proxy.logger = value
  end

  def request_format(value)
    proxy.request_format = value
  end

  def response_format(value)
    proxy.response_format = value
  end

  def post(path, body:)
    proxy.http_verb = :post
    proxy.path = path
    proxy.body = body
  end

  def get(path, query_params: {})
    proxy.http_verb = :get
    proxy.path = path
    proxy.query_params = query_params
  end

  def initialize_proxy
    @proxy = RequestProxy.new(wrapper: self, actions: public_methods(false))

    site _site
    request_format _request_format
    response_format _response_format
    logger _logger
  end
end
