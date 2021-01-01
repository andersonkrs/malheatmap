class UsersController < ApplicationController
  helper MAL::URLS
  helper CalendarHelper

  around_action :set_user
  before_action :set_selected_year

  def show
    @date_range = helpers.calculate_date_range_for_year(@selected_year)
    @activities = @user.activities.for_date_range(@date_range).ordered_as_timeline
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def set_user(&block)
    @user = User.find_by!(username: params[:username])

    @user.with_time_zone(&block)
  end
  # rubocop:enable Naming/AccessorMethodName

  def set_selected_year
    @selected_year = if @user.active_years.include?(year_param)
                       year_param
                     else
                       Time.zone.today.year
                     end
  end

  def year_param
    @year_param ||= params[:year].to_i
  end
end
