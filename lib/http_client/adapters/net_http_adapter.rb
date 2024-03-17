module HttpClient
  module Adapters
    class NetHttpAdapter
      def initialize
        @connection = Net::HTTP::Persistent.new
        connection.idle_timeout = 5
        connection.keep_alive = 300
        super
      end

      # @param [HttpClient::Request] wrapper
      # @return Net::HTTPResponse
      def execute!(wrapper)
        @wrapper = wrapper

        req = case http_verb.to_s
        when "post"
          Net::HTTP::Post.new(uri)
        when "get"
          Net::HTTP::Get.new(uri)
        end

        req = set_request_data(req)
        req = set_headers(req)

        logger.debug("Request: #{http_verb} #{req.uri}")

        req.each_header { |header| logger.debug("Request: #{header}") }

        res = connection.request(req.uri, req) { |response| response }

        logger.debug("Response: #{res.code}")
        logger.debug(res.body&.pretty_inspect.to_s)

        res
      end

      private

      attr_reader :connection, :wrapper

      delegate :http_verb, :uri, :logger, :content_type, :headers, :body, to: :wrapper

      def set_request_data(request)
        case http_verb.to_s
        when "post", "put", "patch"
          set_body(request)
        else
          request
        end
      end

      def set_body(request)
        case content_type.to_s
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
end
