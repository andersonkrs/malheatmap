module UserQueries
  class ActivitiesForDateRange < ApplicationQuery
    through Activity

    def execute
      relation
        .includes(:item)
        .joins(:item)
        .where(user: params.user, date: params.range)
        .order(date: :desc, name: :asc)
    end
  end
end
