class User
  module Authenticatable
    extend ActiveSupport::Concern
    extend ActiveModel::Callbacks

    include HttpClient::NetHttpRefinements

    included do
      define_model_callbacks :authentication, only: %i[after before]

      has_many :access_tokens, inverse_of: :user, dependent: :delete_all do
        def replace_current!(**attributes)
          transaction(requires_new: true) do
            where(discarded_at: nil).update_all(discarded_at: Time.current)
            create!(**attributes)
          end
        end

        def current_token
          current&.token
        end

        def current
          where(discarded_at: nil).first
        end
      end
    end

    class_methods do
      def generate_oath_link
        challenge = OAuthChallenge.create

        MAL::URLS.oauth_authorize_url(
          response_type: :code,
          client_id: Rails.configuration.mal_api[:client_id],
          code_challenge: challenge.code,
          state: challenge.state,
          code_challenge_method: "plain"
        )
      end

      def find_or_create_from_oauth_callback(oauth_code:, state:)
        challenge = OAuthChallenge.pop(state)
        token_response = MAL::ApiClient.create_access_token(code: oauth_code, code_challenge: challenge.code)

        case token_response
        in Net::HTTPCreated => response
          process_user_creation(response.parsed)
        else
          nil
        end
      end
    end

    def mal_account_linked?
      mal_id.present?
    end

    def legacy_account? = !mal_account_linked?

    private

    def process_user_creation(token_data)
      client = MAL::ApiClient.with(access_token: token_data["access_token"])

      response = client.user_profile
      case response
      in Net::HTTPSuccess => response
        user = process_user_data(response.parsed)

        user.run_callbacks(:authentication) do
          user.transaction do
            user.save!
            user.access_tokens.replace_current!(
              token: token_data["access_token"],
              refresh_token: token_data["refresh_token"],
              token_expires_at: Time.zone.at(token_data["expires_in"])
            )
          end
        end
      else
        Rails.error.report(response.body)
        nil
      end
    end

    def process_user_data(user_data)
      user = find_or_initialize_mal_user(user_data)
      user.mal_id ||= user_data["id"]
      user.username = user_data["name"]
      user.location = user_data["location"]
      user.time_zone = user_data["time_zone"]
      user.avatar_url = user_data["picture"]
      user.profile_data_updated_at = Time.current
      user
    end

    # Tries to find a profile that has not been yet associated with a MAL profile and sets the MAL id,
    # otherwise find a user that has already been associated or create a new one
    def find_or_initialize_mal_user(user_data)
      User.find_by(username: user_data["name"], mal_id: nil) || User.find_or_initialize_by(mal_id: user_data["id"])
    end
  end
end
