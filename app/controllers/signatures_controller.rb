class SignaturesController < ApplicationController
  def show
    user = User.find_by!(username: params[:user_username])

    redirect_to url_for(user.signature)
  end
end
