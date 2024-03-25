module HttpClient
  module Parameterized
    extend ActiveSupport::Concern

    included do
      attr_writer :params

      def params
        @params ||= {}
      end
    end

    module ClassMethods
      def with(params)
        HttpClient::Parameterized::Action.new(self, params)
      end
    end

    class Action
      def initialize(client, params)
        @client, @params = client, params
      end

      private

      def method_missing(method, *args)
        if @client.action_methods.include?(method.name)
          @client.new.tap do |client|
            client.params = @params
            client.process(method.name)
          end
        else
          super
        end
      end

      def respond_to_missing?(method, include_all = false)
        @client.respond_to?(method, include_all)
      end
    end
  end
end
