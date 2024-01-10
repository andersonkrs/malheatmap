class CalendarsController < ApplicationController
  def show
    @user = User.find_by!(username: params[:user_username])
    @calendar = @user.calendars.fetch(params[:year])

    fresh_when @calendar
  end
end
