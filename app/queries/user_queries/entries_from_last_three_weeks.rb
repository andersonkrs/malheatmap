module UserQueries
  class EntriesFromLastThreeWeeks < ApplicationQuery
    through Entry

    def execute
      relation.where(user: params.user).where("timestamp >= ?", 3.weeks.ago.at_beginning_of_day.in_time_zone)
    end
  end
end
