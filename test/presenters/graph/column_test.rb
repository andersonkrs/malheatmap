require "test_helper"

module Graph
  module ColumnTest
    class LabelTest < ActiveSupport::TestCase
      test "returns short month name based on given month number" do
        column = Graph::Column.new(month: 2)

        result = column.label

        assert_equal "Feb", result
      end
    end

    class CssWidthTest < ActiveSupport::TestCase
      test "returns css expression to calculate column width" do
        column = Graph::Column.new(width: 2)

        result = column.css_width

        assert_equal "calc(var(--week-width) * 2)", result
      end
    end
  end
end
