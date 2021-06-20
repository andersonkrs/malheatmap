# Monkey patch to make the gem works on Ruby 3 :(

module Imatcher
  module Modes
    class RGB < Base
      def initialize(options)
        super(**options)
      end
    end
  end
end

module Imatcher
  module Modes
    class Grayscale < Base
      def initialize(options)
        super(**options)
      end
    end
  end
end

module Imatcher
  module Modes
    class Delta < Base
      def initialize(options)
        super(**options)
      end
    end
  end
end
