class CalendarComponent < ViewComponent::Base
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
      if month_ends_on_the_last_saturday_of_the_last_week? || last_month?
        weeks.size
      else
        weeks.size - 1
      end
    end

    private

    def month_ends_on_the_last_saturday_of_the_last_week?
      last_week = weeks.last
      last_week_day = last_week.last

      last_week_day.saturday? && last_week_day == Date.new(year, month, 1).end_of_month
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
