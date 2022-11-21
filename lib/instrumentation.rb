module Instrumentation
  module_function

  def instrument(**options, &block)
    Skylight.instrument(**options) { block.call }
  end
end
