# frozen_string_literal: true
require 'http_client'

module MAL
  module Api
    class Client < HttpClient
      site "https://api.myanimelist.net/v2"
      request_format :json
      response_format :json

      logger Rails.logger.tagged(self.name)

      def create_access_token(code:, code_challenge:)
        site "https://myanimelist.net/v1"
        request_format :form_url_encoded

        post("oauth2/token", body: {
          client_id: params[:client_id],
          client_secret: params[:client_secret],
          code: code,
          code_verifier: code_challenge,
          grant_type: "authorization_code",
        })
      end

      def user_profile(access_token:)
        header "Authorization" => "Bearer #{access_token}"

        get("users/@me", query_params: { fields: %i[time_zone location].join(",") })
      end
    end
  end
end
