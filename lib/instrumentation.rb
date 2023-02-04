module Instrumentation
  module_function

  def instrument(**options, &)
    Skylight.instrument(**options, &)
  end
end
