class UsersController < ApplicationController
  helper MAL::URLS
  helper CalendarHelper

  before_action :set_user
  before_action :set_user_years
  before_action :set_selected_year

  around_action :switch_to_user_time_zone

  def show
    @date_range = helpers.calculate_date_range_for_year(@selected_year)
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
                       Time.find_zone(@user.time_zone).today.year
                     end
  end

  def switch_to_user_time_zone(&block)
    @user.with_time_zone { block.call }
  end
end
