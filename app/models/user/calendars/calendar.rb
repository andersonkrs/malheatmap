class User
  module Calendars
    class Calendar
      attr_reader :user, :year, :dates

      def initialize(user:, year:)
        super()
        @user = user
        @year = year
        current_date = Time.zone.today

        @dates = if current_date.year == year
                   prior_sunday(1.year.ago(current_date))..current_date
                 else
                   prior_sunday(Date.new(year, 1, 1))..Date.new(year, 12, 31)
                 end
      end

      def activities
        user.activities.where(date: dates)
      end

      def activities_amount_sum_per_day
        grouped_activities = activities.group(:date).sum(:amount)

        dates.index_with do |date|
          grouped_activities.fetch(date, 0)
        end
      end

      private

      def prior_sunday(date)
        date - date.wday
      end
    end
  end
end
