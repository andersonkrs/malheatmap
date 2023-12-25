module Instrumentation
  module_function

  def instrument(**, &)
    Skylight.instrument(**, &)
  end
end
