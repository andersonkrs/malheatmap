class UsersController < ApplicationController
  helper MAL::URLS

  around_action :set_user
  before_action :set_selected_year

  def show
    @calendar = @user.calendars[@selected_year]
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def set_user(&)
    @user = User.find_by!(username: params[:username])

    @user.with_time_zone(&)
  end
  # rubocop:enable Naming/AccessorMethodName

  def set_selected_year
    @selected_year = if @user.calendars.exists?(year_param)
                       year_param
                     else
                       Time.zone.today.year
                     end
  end

  def year_param
    @year_param ||= ActiveModel::Type::Integer.new.cast(params[:year])
  end
end
