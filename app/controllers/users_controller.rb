class UsersController < ApplicationController
  helper MAL::URLS

  before_action :set_selected_year, only: %i[show]
  before_action :set_date_range, only: %i[show]

  def show
    @user = User.find_by!(username: params[:id])
    @activities = UserQueries::ActivitiesForDateRange.execute(user: @user, range: @date_range)
    @years = UserQueries::ActiveYears.execute(user: @user)
  end

  private

  def set_selected_year
    @selected_year = (params[:year] || Time.zone.today.year).to_i
  end

  def set_date_range
    @date_range = Graph::DateRange.calculate_for(year: @selected_year)
  end
end
