class User
  module Authenticatable
    class OAuthChallenge
      attr_reader :code, :state

      def initialize(code:, state:)
        @code = code
        @state = state
      end

      def self.pop(state)
        code = Rails.cache.read(challenge_cache_key(state)).tap { Rails.cache.delete(challenge_cache_key(state)) }
        self.new(code: code, state: state)
      end

      def self.create(state)
        code = SecureRandom.urlsafe_base64(43)
        state = SecureRandom.urlsafe_base64(12)

        Rails.cache.write(challenge_cache_key(state), code, expires_in: 5.minutes)

        self.new(code: code, state: state)
      end

      def self.challenge_cache_key(state)
        "mal/oauth/#{state}/code_challenge"
      end
    end
  end
end
