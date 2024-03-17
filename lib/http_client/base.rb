module HttpClient
  class Base < AbstractController::Base
    abstract!

    include ActiveSupport::Configurable

    config_accessor :site
    config_accessor :content_type, default: :json
    config_accessor :default_headers, default: {}

    config_accessor :logger, default: Logger.new(IO::NULL)
    config_accessor :adapter, default: Adapters::NetHttpAdapter.new

    include Callbacks
    include Parameterized
    include Rescuable

    include AbstractController::Callbacks

    def process(method_name, ...) # :nodoc:
      payload = {
        client: self.class.name,
        action: method_name
      }

      ActiveSupport::Notifications.instrument("process.http_client", payload) do
        super
      end
    end

    def self.method_missing(method, ...)
      new.process(method.name, ...) if action_methods.include?(method.name)
    end

    def self.respond_to_missing?(method)
      action_methods.include?(method.name)
    end

    private

    def header(values)
      config.default_headers.merge!(values)
    end

    def post(path, body:)
      req = HttpClient::Request.new(client: self)
      req.http_verb = :post
      req.path = path
      req.body = body
      req.perform
    end

    def get(path, query_params: {})
      req = HttpClient::Request.new(client: self)
      req.http_verb = :get
      req.path = path
      req.query_params = query_params
      req.perform
    end
  end
end
