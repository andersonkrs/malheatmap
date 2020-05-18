class UsersController < ApplicationController
  helper MAL::URLS

  before_action :set_year, only: %i[show]
  before_action :set_range, only: %i[show]

  def show
    @user = User.find_by!(username: params[:id])
    @activities = @user
                    .activities
                    .includes(:item)
                    .joins(:item)
                    .where(date: @range)
                    .order(date: :desc, name: :asc)
  end

  private

  def set_year
    @year = (params[:year] || Time.zone.today.year).to_i
  end

  def set_range
    @range = GraphRange.new(@year).calculate
  end
end
