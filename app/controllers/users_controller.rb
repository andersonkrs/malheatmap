class UsersController < ApplicationController
  include UserScoped

  def show
    @calendar = @user.calendars.fetch(params[:year], Time.current.year)

    fresh_when [@user, @calendar]
  end

  private

  def show_waiting_mal_sync?
    @user.current? && @user.never_synced_mal?
  end

  helper_method :show_waiting_mal_sync?
end
