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

    class VisibleTest < ActiveSupport::TestCase
      test "returns true if width is greater than one" do
        column = Graph::Column.new(width: 2)

        result = column.visible?

        assert result
      end

      test "returns false if width is equal to one" do
        column = Graph::Column.new(width: 1)

        result = column.visible?

        assert_not result
      end

      test "returns false if width is zero" do
        column = Graph::Column.new(width: 0)

        result = column.visible?

        assert_not result
      end
    end
  end
end
