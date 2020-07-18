module Patterns
  module Pipeline
    extend ActiveSupport::Concern
    include Service

    included do
      class_attribute :steps, default: []

      def call
        steps.each do |step|
          next unless should_run?(step)

          result = step[:service].call(context.to_h)
          @context = context.merge(result)

          context.fail if result.failure?
        end
      end

      private

      def should_run?(step)
        filter = step[:if]

        filter.present? ? send(filter) : true
      end
    end

    class_methods do
      def step(service, filters = {})
        steps << { service: service, **filters }
      end
    end
  end
end
