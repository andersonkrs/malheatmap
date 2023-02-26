require 'mal'

class SessionsController < ApplicationController
  before_action :redirect_to_current_user_page, only: [:index, :create], if: -> { helpers.signed_in? }

  def index
  end

  def create
    state, code_challenge = generate_code_challenge

    redirect_to MAL::URLS.oauth_authorize_url(
      response_type: :code,
      client_id: "18c15be6e0b2df8179dd4eaa5cffd42b", # TODO: Move to secret
      code_challenge: code_challenge,
      state: state,
      code_challenge_method: "plain",
    ), allow_other_host: true
  end

  def destroy
    if helpers.signed_in?
      session[:current_user_id] = nil
    end

    redirect_to sessions_path
  end

  def callback
    @client = MAL::Api::Client.with(
      client_id: "18c15be6e0b2df8179dd4eaa5cffd42b",
      client_secret: "8291aa755d8d63b046eea4d84f54beda8dcd119a65d6ae303790a5c7a41c6098",
    )

    code_challenge = fetch_code_challenge(params[:state])
    token_response = @client.create_access_token(code: params[:code], code_challenge: code_challenge)

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
    response = @client.user_profile(access_token: token_data["access_token"])

    if response.success?
      user = find_or_initialize_mal_user(response)
      user.mal_id ||= response.data["id"]
      user.username = response.data["name"]
      user.location = response.data["location"]
      user.time_zone = response.data["time_zone"]
      user.avatar_url = response.data["picture"]
      user.profile_data_updated_at = Time.current
      user.save!

      session[:current_user_id] = user.id

      redirect_to user_path(user)
    else
      redirect_to internal_error_path
    end
  end

  def generate_code_challenge
    code_challenge = SecureRandom.urlsafe_base64(43)
    code_state = SecureRandom.urlsafe_base64(12)

    Rails.cache.write(challenge_cache_key(code_state), code_challenge, expires_in: 5.minutes)

    [code_state, code_challenge]
  end

  def fetch_code_challenge(code_state)
    Rails.cache.read(challenge_cache_key(code_state)).tap do
      Rails.cache.delete(challenge_cache_key(code_state))
    end
  end

  def challenge_cache_key(code_state)
    "mal/oauth/#{code_state}/code_challenge"
  end

  # Tries to find a profile that has not been yet associated with a MAL profile and sets the MAL id,
  # otherwise find a user that has already been associated or create a new one
  def find_or_initialize_mal_user(response)
    User.find_by(username: response.data["name"], mal_id: nil) || User.find_by(mal_id: response.data["id"]) || User.new
  end
end
