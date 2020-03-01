require "virtus"

module CCEngine
  module Location
    class Position
      include Virtus.model(strict: true)

      attribute :path, String
      attribute :start_position
      attribute :end_position

      def to_hash
        {
          path: path,
          positions: {
            begin: start_position.to_hash,
            end: end_position.to_hash
          }
        }
      end
    end
  end
end
