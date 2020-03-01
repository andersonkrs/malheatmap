require "virtus"

module CCEngine
  module Position
    class Grid
      include Virtus.model(strict: true)

      attribute :line, Integer
      attribute :column, Integer

      def to_hash
        {
          line: line,
          column: column
        }
      end
    end
  end
end
