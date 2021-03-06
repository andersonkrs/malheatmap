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

      def each(&block)
        to_a.each(&block)
      end

      def to_a
        active_years.map do |year|
          Calendar.new(user: user, year: year)
        end
      end

      def exists?(year)
        self[year].present?
      end

      def [](year)
        find { |calendar| calendar.year == year }
      end

      def active_years
        @active_years ||= begin
          first_year = [user.created_at.year, user.activities.first_date&.year].compact.min

          (first_year..Time.current.year)
        end
      end
    end
  end
end
