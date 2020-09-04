class UsersController < ApplicationController
  helper MAL::URLS

  before_action :set_user, only: :show
  before_action :set_user_years, only: :show
  before_action :set_selected_year, only: :show

  def show
    @date_range = Calendar::CalculateDateRange.call(year: @selected_year).range
    @activities = @user.activities.for_date_range(@date_range).ordered_as_timeline
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end

  def set_user_years
    @years = @user.activities.unique_years
  end

  def set_selected_year
    @selected_year = if @years.include?(params[:year].to_i)
                       params[:year].to_i
                     else
                       Time.zone.today.year
                     end
  end
end
