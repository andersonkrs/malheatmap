# Monkey patch to make the gem works on Ruby 3 :(

module Imatcher
  module Modes
  class RGB < Imatcher::Modes::Base
  def initialize(options)
    super(**options)
  end
  end
  end
end

module Imatcher
  module Modes
  class Grayscale < Imatcher::Modes::Base
  def initialize(options)
    super(**options)
  end
  end
  end
end

module Imatcher
  module Modes
  class Delta < Imatcher::Modes::Base
  def initialize(options)
    super(**options)
  end
  end
  end
end
