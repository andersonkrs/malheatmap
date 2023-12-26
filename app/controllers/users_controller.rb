class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])

    render locals: { selected_year: params[:year] }
  end

  private

  def show_waiting_mal_sync?
    @user == Current.user && @user.never_synced_mal?
  end

  helper_method :show_waiting_mal_sync?
end
