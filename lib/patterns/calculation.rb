module Patterns
  class Calculation
    def self.calculate_for(**args)
      new(**args).calculate
    end

    def initialize(**args)
      @params = OpenStruct.new(**args)
    end

    def calculate; end

    private

    attr_reader :params
  end
end
