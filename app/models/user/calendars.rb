# Calendars is a abstraction around user activities/dates
#
# It works like a pagination by year, each user's calendar is represented by a year, a year is not
# necessarily from JAN 01 to DEC 31.
#
# The current year calendar covers the current date as the end date and it starts
# one year ago, counting from the current date, this rule is to provide a better calendar when the user is looking
# for the current data, since it is a core business rule to show the user progress along the way not just the data
# for that year.
#
# The available calendars are calculated based either on the date that the user subscribed on MAL Heatmap or the date
# of the very first activity until the current year. Therefore a user subscribed in 2017 will have 3 years of calendar
# in 2020
module User
  module Calendars
    extend ActiveSupport::Concern

    def calendars
      @calendars ||= CalendarList.new(self)
    end

    def reload(options = nil)
      instance = super(options)
      delete_cached_calendar
      instance
    end

    private

    def delete_cached_calendar
      return unless instance_variable_defined? :@calendars
      remove_instance_variable :@calendars
    end
  end
end
