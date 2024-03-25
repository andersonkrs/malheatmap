class SessionsController < ApplicationController
  before_action :redirect_to_current_user_page, only: %i[index create], if: -> { helpers.signed_in? }

  def index
  end

  def create
    oauth_link = User.generate_oauth_link

    redurect_to oauth_link
  end

  def destroy
    session[:current_user_id] = nil if helpers.signed_in?
    reset_session

    redirect_to sessions_path
  end

  def callback
    if (user = User.find_or_create_from_oauth_callback(oauth_code: params[:code], state: params[:state]))
      reset_session
      session[:current_user_id] = user.id
      Current.user = user

      redirect_to user_path(Current.user)
    else
      redirect_to internal_error_path
    end
  end
end
