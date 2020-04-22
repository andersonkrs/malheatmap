module Graph
  Column = Struct.new(:month, :year, :width, keyword_init: true) do
    def label
      I18n.t("date.abbr_month_names")[month]
    end

    def css_width
      "calc(var(--week-width) * #{width})"
    end
  end
end
