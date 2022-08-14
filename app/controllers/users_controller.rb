class UsersController < ApplicationController
  helper ::MAL::URLS

  around_action :set_user

  def show
    @selected_year = if @user.calendars.exists?(year_param)
                       year_param
                     else
                       Time.zone.today.year
                     end

    @calendar = @user.calendars[@selected_year]
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def set_user(&block)
    @user = User.find_by!(username: params[:username])

    @user.with_time_zone(&block)
  end
  # rubocop:enable Naming/AccessorMethodName

  def year_param
    @year_param ||= ActiveModel::Type::Integer.new.cast(params[:year])
  end
end
