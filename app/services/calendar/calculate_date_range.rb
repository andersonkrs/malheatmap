module Calendar
  class CalculateDateRange < ApplicationService
    delegate :year, to: :context

    def call
      if current_year?
        first_day = 1.year.ago(current_date)
        last_day = current_date
      else
        first_day = Date.new(year, 1, 1)
        last_day = Date.new(year, 12, 31)
      end

      context.range = (prior_sunday(first_day)..last_day)
    end

    private

    def current_year?
      year == current_date.year
    end

    def current_date
      @current_date ||= Time.zone.today
    end

    def prior_sunday(date)
      date - date.wday
    end
  end
end
