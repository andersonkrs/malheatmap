class UsersController < ApplicationController
  helper MAL::URLS

  def show
    @user = User.find_by!(username: params[:id])
    @activities = @user.activities.eager_load(:item)
  end
end
