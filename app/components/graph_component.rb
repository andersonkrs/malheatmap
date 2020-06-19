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
    @squares = Graph::CalculateSquares.call(date_range: date_range, activities: activities).squares
    @columns = Graph::CalculateColumns.call(squares: @squares).columns
  end

  def columns_css_grid
    @columns.map(&:css_width).join(" ")
  end

  def days_names
    I18n.t("date.abbr_day_names").compact
  end
end
