class User
  class CalendarDates
    def range_for_current_year
      range_for_year(Time.zone.today.year)
    end

    def range_for_year(year)
      current_date = Time.zone.today

      if current_date.year == year
        first_day = 1.year.ago(current_date)
        last_day = current_date
      else
        first_day = Date.new(year, 1, 1)
        last_day = Date.new(year, 12, 31)
      end

      (prior_sunday(first_day)..last_day)
    end

    private

    def prior_sunday(date)
      date - date.wday
    end
  end
end
