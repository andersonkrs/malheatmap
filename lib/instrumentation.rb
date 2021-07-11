module Instrumentation
  module_function

  def instrument(**options, &block)
    Skylight.instrument(**options) do
      block.call
    end
  end
end
