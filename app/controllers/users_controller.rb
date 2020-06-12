class UsersController < ApplicationController
  helper MAL::URLS

  before_action :set_year, only: %i[show]
  before_action :set_range, only: %i[show]

  def show
    @user = User.find_by!(username: params[:id])
    @activities = UserQueries::ActivitiesForDateRange.execute(user: @user, range: @range)
    @active_years = UserQueries::ActiveYears.execute(user: @user)
  end

  private

  def set_year
    @year = (params[:year] || Time.zone.today.year).to_i
  end

  def set_range
    @range = Graph::DateRange.calculate_for(year: @year)
  end
end
