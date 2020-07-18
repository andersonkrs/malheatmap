require "test_helper"

module Patterns
  class ServiceTest < ActiveSupport::TestCase
    class CalculationService
      include Patterns::Service

      before_call do
        context.before_executed = true
      end

      after_call do
        context.after_executed = true
      end

      around_call do |block|
        context.around_executed = true
        block.call
      end

      rescue_from ZeroDivisionError do
        context.rescue_executed = true
      end

      ensure_call do
        context.ensure_executed = true
      end

      def call
        context.fail(message: "Invalid input") if context.number_1.is_a? String

        context.result = context.number_1 / context.number_2
      end

      def rollback
        context.rollback_executed = true
      end
    end

    test "executes every callback when call" do
      context = CalculationService.call(number_1: 6, number_2: 2)

      assert context.before_executed
      assert context.after_executed
      assert context.around_executed
      assert context.ensure_executed
    end

    test "executes callbacks when call raises an error" do
      context = CalculationService.call(number_1: 2, number_2: 0)

      assert context.rescue_executed
      assert context.ensure_executed
      assert context.rollback_executed
    end

    test "returns context as outcome" do
      context = CalculationService.call(number_1: 6, number_2: 2)

      assert context.success?
      assert_equal 3, context.result

      context = CalculationService.call!(number_1: 6, number_2: 2)

      assert context.success?
      assert_equal 3, context.result
    end

    test "returns failure when mark context as failed" do
      context = CalculationService.call(number_1: "Invalid")

      assert context.failure?
      assert_not context.success?
      assert_equal "Invalid input", context.message

      exception = assert_raises Patterns::Service::Failure do
        CalculationService.call!(number_1: "Invalid")
      end

      assert "Invalid input", exception.context.message
      assert exception.context.failure?
    end
  end
end
