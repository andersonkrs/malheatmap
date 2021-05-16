class CalendarComponent < ViewComponent::Base
  # Component that represents the activities calendar
  # The calendar always start on a Sunday
  #
  #              |Jan                |Feb                |Mar                |Apr
  #        SUN   04   11   18   25   01   08   15   22   29   07   14   21   28   04
  #        MON   05   12   19   26   02   09   16   23   01   08   15   22   29   05
  #        TUE   06   13   20   27   03   10   17   24   02   09   16   23   30   06
  #        WED   07   14   21   28   04   11   18   25   03   10   17   24   31   07
  #        THU   08   15   22   29   05   12   19   26   04   11   18   25   01
  #        FRI   09   16   23   30   06   13   20   27   05   12   19   26   02
  #        SAT   10   17   24   31   07   14   21   28   06   13   20   27   03
  #
  # Each square represents a day, each group of 7 squares is a week column.
  # The months' headers are calculated based on the number of weeks depending how many week columns the month is
  # present in, the same week column can contain days of following and/or previous months.
  #
  # The number of weeks is subtracted by 1 in order to keep the month's name on the exact column that it starts.
  # Usually a month will start and at the end or in the middle of a week column,
  # sharing the same week with the previous month and next month.
  #
  # If the month ends on a saturday, we dont need to subtract, since the next week will be fully taken by
  # following month.
  #
  # If the month is the last of the date range, we do not subtract, this adds the trailing amount of space to the
  # last month in order to match the sum of all months' widths with the total of weeks
  #
  # width of the month's header = Number of weeks of the month * --week-width in pixes

  Month = Struct.new(:month, :year, :weeks, :last, keyword_init: true) do
    def label
      I18n.t("date.abbr_month_names")[month]
    end

    def visible?
      width > 1
    end

    def css_width
      "calc(var(--week-width) * #{width}) /* #{label} */"
    end

    def width
      if month_ends_on_a_saturday? || last_month?
        weeks.size
      else
        weeks.size - 1
      end
    end

    private

    def month_ends_on_a_saturday?
      last_week = weeks.last
      last_week_day = last_week.last
      last_month_day = Date.new(year, month, 1).end_of_month

      last_week_day.saturday? && last_week_day == last_month_day
    end

    def last_month?
      last
    end
  end

  Square = Struct.new(:amount, :date, keyword_init: true) do
    def level
      return 0 if amount.negative?

      case amount
      when 0 then 0
      when (1..4) then 1
      when (5..8) then 2
      when (9..12) then 3
      else 4
      end
    end

    def hint
      formatted_date = I18n.l(date, format: :long)
      I18n.t("calendar_component.activities_on", count: amount, date: formatted_date)
    end
  end

  def initialize(date_range:, activities:)
    super

    @date_range = date_range
    @activities = activities
    @weeks = @date_range.each_slice(7).to_a

    create_squares
    create_months
  end

  def months_css_grid
    @months.map(&:css_width).join(" ")
  end

  def days_names
    I18n.t("date.abbr_day_names").compact
  end

  private

  def grouped_activities
    @grouped_activities ||= @activities.group_by(&:date)
  end

  def create_squares
    @squares = @date_range.map do |date|
      amount = grouped_activities.fetch(date, []).sum(&:amount)
      Square.new(date: date, amount: amount)
    end
  end

  def create_months
    last_date = @date_range.last

    @months = @date_range.uniq(&:beginning_of_month).map do |date|
      Month.new(month: date.month,
                year: date.year,
                weeks: weeks_containing_month_year(date),
                last: last_date.beginning_of_month == date)
    end
  end

  def weeks_containing_month_year(date)
    @weeks.select do |week|
      week.any? { |day| day.beginning_of_month == date.beginning_of_month }
    end
  end
end
