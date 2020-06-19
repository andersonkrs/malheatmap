module Graph
  class CalculateColumns < ApplicationService
    delegate :squares, :columns, to: :context

    def call
      create_columns_by_year_and_month
      define_columns_widths
    end

    private

    def dates
      squares.map(&:date)
    end

    def weeks
      dates.each_slice(7).to_a
    end

    def create_columns_by_year_and_month
      context.columns = dates
                          .map { |date| GraphComponent::Column.new(month: date.month, year: date.year) }
                          .uniq { |column| [column.month, column.year] }
    end

    def define_columns_widths
      columns.each_with_index do |current_column, index|
        previous_column = index.zero? ? nil : columns[index - 1]

        calculate_column_width(current_column, previous_column)
      end
    end

    def calculate_column_width(current_column, previous_column)
      current_column.width = weeks_count_in_column(current_column)
      current_column.width -= 1 unless current_column == columns.last

      adjust_columns_sizes(current_column, previous_column)
    end

    def weeks_count_in_column(column)
      weeks.count do |week|
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
      weeks.any? { |week| week.first == first_month_day }
    end
  end
end
