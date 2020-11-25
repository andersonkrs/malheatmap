module MAL
  module Stubbing
    extend ActiveSupport::Concern

    included do
      class_attribute :sttubed_responses, default: []
    end

    class_methods do
      def stub_response(username, response)
        sttubed_responses << { username: username, response: response }
      end

      def remove_stubs
        self.sttubed_responses = []
      end
    end

    private

    def stubed_response(username)
      stub = stub_for(username)
      self.class.sttubed_responses.delete(stub)

      response = stub[:response]
      raise response if response.is_a?(Exception)

      response
    end

    def stub_for(username)
      self.class.sttubed_responses.detect { |hash| hash[:username] == username }
    end

    def stubed?(username)
      stub_for(username).present?
    end
  end
end
