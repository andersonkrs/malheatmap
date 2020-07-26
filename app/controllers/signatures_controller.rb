class SignaturesController < ApplicationController
  before_action :set_user

  def show
    signature = @user.signature.variant(resize_to_limit: [600, 150])

    redirect_to url_for(signature)
  end

  private

  def set_user
    @user = User.find_by!(username: params[:user_username])
  end
end
