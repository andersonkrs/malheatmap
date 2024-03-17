module MAL
  class ApiClient < ApplicationClient
    self.site = "https://api.myanimelist.net/v2"
    self.request_format = :json
    self.response_format = :json

    before_action { header "Authorization" => "Bearer #{params[:access_token]}" if params[:access_token].present? }

    def create_access_token(code:, code_challenge:)
      post(
        "oauth2/token",
        site: "https://myanimelist.net/v1",
        request_format: :form_url_encoded,
        body: {
          client_id: Rails.configuration.mal_api[:client_id],
          client_secret: Rails.configuration.mal_api[:client_secret],
          code:,
          code_verifier: code_challenge,
          grant_type: "authorization_code"
        }
      )
    end

    def user_profile
      get("users/@me", query_params: { fields: %i[time_zone location].join(",") })
    end
  end
end
