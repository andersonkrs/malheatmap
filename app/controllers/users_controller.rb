class UsersController < ApplicationController
  helper MAL::URLS

  def show
    @user = User.includes(:entries).find_by!(username: params[:id])
  end
end
