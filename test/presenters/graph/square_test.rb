require "test_helper"

module Graph
  module SquareTest
    class LabelTest < ActiveSupport::TestCase
      test "returns number of activities and full date" do
        square = Graph::Square.new(amount: 2, date: Date.new(2020, 4, 1))

        result = square.label

        assert_equal "2 activities on April 01, 2020", result
      end
    end

    class LevelTest < ActiveSupport::TestCase
      test "returns each level correctly based on saquare's amount" do
        assert_square_range_level(level: 1, range: (1..4))
        assert_square_range_level(level: 2, range: (5..8))
        assert_square_range_level(level: 3, range: (9..12))
        assert_square_range_level(level: 4, range: (13..100))
      end

      test "returns level zero when there's no amount on date" do
        square = Graph::Square.new(amount: 0, date: Time.zone.today)

        result = square.level

        assert result.zero?
      end

      private

      def assert_square_range_level(level:, range:)
        range.each do |amount|
          square = Graph::Square.new(amount: amount, date: Time.zone.today)

          assert_equal level, square.level
        end
      end
    end
  end
end
