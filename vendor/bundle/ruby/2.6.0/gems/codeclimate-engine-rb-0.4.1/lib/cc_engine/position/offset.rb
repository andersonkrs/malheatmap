require "virtus"

module CCEngine
  module Position
    class Offset
      include Virtus.model(strict: true)

      attribute :offset, Integer

      def to_hash
        {
          offset: offset
        }
      end
    end
  end
end
