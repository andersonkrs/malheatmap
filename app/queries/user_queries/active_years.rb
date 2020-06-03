module UserQueries
  class ActiveYears < ApplicationQuery
    through Activity
    expires_in 12.hours

    def execute
      relation
        .where(user: params.user)
        .select("date_part('year', date) as year")
        .reorder("year DESC")
        .distinct
        .map { |record| record.year.to_i }
    end

    def cache_param
      params.user.cache_key_with_version
    end
  end
end
