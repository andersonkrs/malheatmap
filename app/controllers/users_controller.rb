class UsersController < ApplicationController
  helper MAL::URLS

  before_action :set_range, only: %i[show]

  def show
    @user = User.find_by!(username: params[:id])
    @activities = @user
                    .activities
                    .joins(:item)
                    .eager_load(:item)
                    .where(date: @range)
  end

  private

  def set_range
    @range = GraphRange.new(year_param).calculate
  end

  def year_param
    params.fetch(:year, Time.zone.today.year).to_i
  end
end
