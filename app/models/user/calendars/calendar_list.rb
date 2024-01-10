class User
  module Calendars
    class CalendarList
      include Enumerable

      attr_reader :user

      delegate :size, :first, :second, :third, :fourth, :fifth, to: :to_a

      def initialize(user)
        super()
        @user = user
      end

      def each(&)
        to_a.each(&)
      end

      def to_a
        active_years.map { |year| User::Calendars::Calendar.new(user: user, year: year) }
      end

      def exists?(year)
        self[year].present?
      end

      def [](year)
        return if year.blank?

        find { |calendar| calendar.year.to_s == year.to_s }
      end

      def fetch(year, fallback = nil)
        result = self[year]

        return result if result.present?

        raise KeyError, key: year if fallback.blank?

        self[fallback]
      end

      def active_years
        @active_years ||=
          begin
            first_year = [user.created_at.year, user.activities.minimum(:date)&.year].compact.min

            (first_year..Time.current.year)
          end
      end

      def current
        self[Time.current.year]
      end

      alias current_year current
    end
  end
end
