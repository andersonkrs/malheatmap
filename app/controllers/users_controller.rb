class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @calendar = @user.calendars.fetch(params[:year], Time.current.year)

    fresh_when [@user, @calendar]
  end

  private

  def show_waiting_mal_sync?
    @user == Current.user && @user.never_synced_mal?
  end

  helper_method :show_waiting_mal_sync?
end
