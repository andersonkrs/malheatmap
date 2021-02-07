class SignaturesController < ApplicationController
  before_action :set_user

  def show
    redirect_to url_for(@user.signature)
  end

  private

  def set_user
    @user = User
              .with_attached_signature
              .find_by!(username: params[:user_username])
  end
end
