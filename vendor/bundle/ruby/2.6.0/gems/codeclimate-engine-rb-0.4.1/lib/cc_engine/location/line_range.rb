require "virtus"

module CCEngine
  module Location
    class LineRange
      include Virtus.model(strict: true)

      attribute :path, String
      attribute :line_range, Range

      def to_hash
        {
          path: path,
          lines: {
            begin: line_range.begin,
            end: line_range.end
          }
        }
      end
    end
  end
end
