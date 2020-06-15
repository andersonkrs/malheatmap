class GraphComponent < ViewComponent::Base
  Column = Struct.new(:month, :year, :width, keyword_init: true) do
    def label
      I18n.t("date.abbr_month_names")[month]
    end

    def css_width
      "calc(var(--week-width) * #{width})"
    end

    def visible?
      width > 1
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
      I18n.t("users.graph.activities_on", count: amount, date: formatted_date)
    end
  end

  def initialize(date_range:, activities:)
    @activities_per_day = calculate_activities_per_day(date_range, activities)
    @columns = []
    @squares = []
    @days = @activities_per_day.keys
    @weeks = @days.each_slice(7).to_a

    calculate
  end

  def css_grid
    @columns.map(&:css_width).join(" ")
  end

  def days_names
    t("date.abbr_day_names").compact
  end

  private

  def calculate
    create_columns_by_year_and_month
    calculate_columns_widths
    create_squares
  end

  def calculate_activities_per_day(range, activities)
    grouped_activities = activities.group_by(&:date)

    range.map do |date|
      total = grouped_activities.fetch(date, []).sum(&:amount)

      [date, total]
    end.to_h
  end

  def create_columns_by_year_and_month
    @columns = @days
                 .map { |date| Column.new(month: date.month, year: date.year) }
                 .uniq { |column| [column.month, column.year] }
  end

  def calculate_columns_widths
    @columns.each_with_index do |current_column, index|
      previous_column = index.zero? ? nil : @columns[index - 1]

      calculate_column_width(current_column, previous_column)
    end
  end

  def calculate_column_width(current_column, previous_column)
    weeks_width = weeks_count_in_column(current_column)

    weeks_width -= 1 unless current_column == @columns.last

    current_column.width = weeks_width

    adjust_columns_sizes(current_column, previous_column)
  end

  def weeks_count_in_column(column)
    @weeks.count do |week|
      week_contains_month_year?(week, column.month, column.year)
    end
  end

  # :reek:ControlParameter
  def week_contains_month_year?(week, month, year)
    week.any? { |day| day.month == month && day.year == year }
  end

  # :reek:FeatureEnvy
  def adjust_columns_sizes(current_column, previous_column)
    return if previous_column.blank?

    first_month_day = Date.new(current_column.year, current_column.month, 1)
    previous_column.width += 1 if any_week_starting_with_first_month_day?(first_month_day)
  end

  def any_week_starting_with_first_month_day?(first_month_day)
    @weeks.any? { |week| week.first == first_month_day }
  end

  def create_squares
    @squares = @activities_per_day.map do |date, amount|
      Square.new(date: date, amount: amount)
    end
  end
end
