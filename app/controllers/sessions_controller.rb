require "mal"

class SessionsController < ApplicationController
  before_action :redirect_to_current_user_page, only: %i[index create], if: -> { helpers.signed_in? }

  def index
  end

  def create
    state, code_challenge = generate_code_challenge

    redirect_to MAL::URLS.oauth_authorize_url(
                  response_type: :code,
                  client_id: Rails.configuration.mal_api[:client_id],
                  code_challenge:,
                  state:,
                  code_challenge_method: "plain"
                ),
                allow_other_host: true
  end

  def destroy
    session[:current_user_id] = nil if helpers.signed_in?

    redirect_to sessions_path
  end

  def callback
    code_challenge = fetch_code_challenge(params[:state])
    token_response = MAL::ApiClient.create_access_token(code: params[:code], code_challenge:)

    if token_response.success?
      process_user_creation(token_response.data)
    else
      redirect_to internal_error_path
    end
  end

  private

  def redirect_to_current_user_page
    redirect_to user_path(Current.user)
  end

  def process_user_creation(token_data)
    response = MAL::ApiClient.with(access_token: token_data["access_token"]).user_profile

    if response.failure?
      ErrorNotifier.capture(response.raw_body)
      redirect_to internal_error_path
    end

    process_user_data(user_data: response.data, token_data:)
    redirect_to user_path(Current.user)
  end

  def process_user_data(user_data:, token_data:)
    user = find_or_initialize_mal_user(user_data)
    user.mal_id ||= user_data["id"]
    user.username = user_data["name"]
    user.location = user_data["location"]
    user.time_zone = user_data["time_zone"]
    user.avatar_url = user_data["picture"]
    user.profile_data_updated_at = Time.current

    user.transaction do
      user.save!
      user.access_tokens.replace_current!(
        token: token_data["access_token"],
        refresh_token: token_data["refresh_token"],
        token_expires_at: Time.zone.at(token_data["expires_in"])
      )
    end

    user.signed_in

    session[:current_user_id] = user.id
    Current.user = user
  end

  def generate_code_challenge
    code_challenge = SecureRandom.urlsafe_base64(43)
    code_state = SecureRandom.urlsafe_base64(12)

    Rails.cache.write(challenge_cache_key(code_state), code_challenge, expires_in: 5.minutes)

    [code_state, code_challenge]
  end

  def fetch_code_challenge(code_state)
    Rails.cache.read(challenge_cache_key(code_state)).tap { Rails.cache.delete(challenge_cache_key(code_state)) }
  end

  def challenge_cache_key(code_state)
    "mal/oauth/#{code_state}/code_challenge"
  end

  # Tries to find a profile that has not been yet associated with a MAL profile and sets the MAL id,
  # otherwise find a user that has already been associated or create a new one
  def find_or_initialize_mal_user(user_data)
    User.find_by(username: user_data["name"], mal_id: nil) || User.find_by(mal_id: user_data["id"]) || User.new
  end
end
