class UsersController < ApplicationController
  helper MAL::URLS

  def show
    @user = User
            .includes(activities: :item)
            .find_by!(username: params[:id])
  end
end
