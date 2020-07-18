require "test_helper"

module Patterns
  class PipelineTest < ActiveSupport::TestCase
    class DivideNumbers
      include Patterns::Service

      def call
        context.fail(message: "Failure") if context.number_2.zero?

        context.result = context.number_1 / context.number_2
      end
    end

    class DoubleResult
      include Patterns::Service

      def call
        context.result = context.result * 2
      end
    end

    class PipelineService
      include Patterns::Pipeline

      step DivideNumbers
      step DoubleResult, if: :result_greater_than_10

      def result_greater_than_10
        context.result > 10
      end
    end

    test "calls each service and returns final context as result" do
      context = PipelineService.call(number_1: 100, number_2: 10)

      assert context.success?
      assert 20, context.result
    end

    test "does not call the step service if the condition is false" do
      context = PipelineService.call(number_1: 10, number_2: 2)

      assert context.success?
      assert 5, context.result
    end

    test "does not call the step service if the previous step fails" do
      context = PipelineService.call(number_1: 2, number_2: 0)

      assert context.failure?
      assert_equal "Failure", context.message
    end
  end
end
