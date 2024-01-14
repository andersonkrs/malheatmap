class User
  module Calendars
    class Calendar
      attr_reader :user, :year, :dates

      def initialize(user:, year:)
        super()
        @user = user
        @year = year
        current_date = Time.zone.today

        @dates =
          if current_date.year == year
            prior_sunday(1.year.ago(current_date))..current_date
          else
            prior_sunday(Date.new(year, 1, 1))..Date.new(year, 12, 31)
          end
      end

      def cache_key
        "calendars/#{year}/#{first_day}:#{last_day}"
      end

      def cache_key_with_version
        "#{cache_key}/#{activities.cache_version}"
      end

      def first_day = dates.first

      def last_day = dates.last

      def updated_at
        @updated_at ||= activities.maximum(:updated_at) || last_day.to_datetime
      end

      def to_param
        year.to_s
      end

      def activities
        user.activities.where(date: dates)
      end

      def activities_amount_sum_per_day
        grouped_activities = activities.group(:date).sum(:amount)

        dates.index_with { |date| grouped_activities.fetch(date, 0) }
      end

      private

      def prior_sunday(date)
        date - date.wday
      end
    end
  end
end
