module Graph
  Square = Struct.new(:amount, :date, keyword_init: true) do
    def level
      case amount
      when 0 then 0
      when (1..4) then 1
      when (5..8) then 2
      when (9..12) then 3
      else 4
      end
    end

    def label
      formated_date = I18n.l(date, format: :long)
      I18n.t("users.graph.activities_on", count: amount, date: formated_date)
    end
  end
end
