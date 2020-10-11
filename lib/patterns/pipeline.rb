module Patterns
  module Pipeline
    extend ActiveSupport::Concern
    include Service

    included do
      class_attribute :steps, default: []

      def run
        run_callbacks :call do
          execute_steps
        end
      end

      private

      def execute_steps
        steps.each do |step|
          next unless should_run?(step)

          execute_step(step)
        end
      end

      def should_run?(step)
        filter = step[:if]

        filter.present? ? send(filter) : true
      end

      def execute_step(step)
        callable = step[:callable]

        if callable.is_a?(Proc)
          instance_eval(&callable)
        else
          result = callable.call(context.to_h)
          context.merge!(result)
          context.fail if result.failure?
        end
      end
    end

    class_methods do
      def step(service = nil, filters = {}, &block)
        steps << { callable: service || block, **filters }
      end
    end
  end
end
