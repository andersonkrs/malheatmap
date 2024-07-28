class TimelinesController < ApplicationController
  include UserScoped

  def show
    @calendar = @user.calendars.fetch(params[:year])

    fresh_when [@user, @calendar]
  end
end
