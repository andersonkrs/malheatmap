module Instrumentation
  module_function

  def instrument(**)
    yield
  end
end
