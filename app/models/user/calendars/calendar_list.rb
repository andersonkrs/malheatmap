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
        active_years.map { |year| User::Calendars::Calendar.new(user:, year:) }
      end

      def exists?(year)
        self[year].present?
      end

      def [](year)
        find { |calendar| calendar.year == year }
      end

      def active_years
        @active_years ||=
          begin
            first_year = [user.created_at.year, user.activities.first_date&.year].compact.min

            (first_year..Time.current.year)
          end
      end
    end
  end
end
