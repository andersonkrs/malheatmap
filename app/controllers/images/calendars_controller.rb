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

    if @user.signature.attached?
      redirect_to @user.signature
    else
      # Neither image exists yet (e.g. generation failed or is still pending).
      # Redirecting to an unattached attachment raised a 500, so retry the
      # generation and answer with a plain 404 instead.
      @user.calendar_images.generate_later
      head :not_found
    end
  end
end
