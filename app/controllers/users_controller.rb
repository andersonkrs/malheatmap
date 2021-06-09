class UsersController < ApplicationController
  helper MAL::URLS

  around_action :set_user
  before_action :set_selected_year

  def show
    @date_range = @user.calendar_dates.range_for_year(@selected_year)
    @activities = @user.activities.where(date: @date_range).ordered_as_timeline
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
    @year_param ||= ActiveModel::Type::Integer.new.cast(params[:year])
  end
end
