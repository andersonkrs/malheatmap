class Images::CalendarsController < ApplicationController
  include UserScoped

  def show
    if small?
      redirect_to @user.calendar_image.variant(:small)
    else
      redirect_to @user.calendar_image.variant(:large)
    end
  end

  private

  def small?
    params[:variant] == "small"
  end
end
