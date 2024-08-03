class Images::CalendarsController < ApplicationController
  include UserScoped

  before_action :check_deprecated_signature_image

  def show
    if small?
      redirect_to @user.calendar_image.variant(:small)
    else
      redirect_to @user.calendar_image
    end
  end

  private

  def small?
    params[:variant] == "small"
  end

  def check_deprecated_signature_image
    return if @user.calendar_image.attached?

    redirect_to @user.signature
  end
end
