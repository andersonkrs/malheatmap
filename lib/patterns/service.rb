module Patterns
  module Service
    extend ActiveSupport::Concern

    class Failure < StandardError
      attr_reader :context

      def initialize(context)
        super
        @context = context
      end
    end

    class Context < OpenStruct
      def merge!(context)
        context.to_h.each do |property, value|
          send("#{property}=", value)
        end

        self
      end

      def success?
        !failure?
      end

      def failure?
        @failure ||= false
      end

      def fail(**args)
        @failure = true
        args.each { |key, value| self[key] = value }
        raise Failure, self
      end
    end

    class ConfiguredService
      def initialize(service_class, **options)
        @service_class = service_class
        @options = options
      end

      def call(**args)
        @service_class.call(@options.merge(args))
      end

      def call!(**args)
        @service_class.call!(@options.merge(args))
      end
    end

    included do
      include ActiveSupport::Callbacks
      include ActiveSupport::Rescuable

      define_callbacks :call

      def initialize(context)
        @context = context
      end

      def run
        run_callbacks :call do
          call
        end
      rescue StandardError => error
        rollback
        rescue_with_handler(error) || raise
      ensure
        ensure_with_handler
      end

      def rollback; end

      private

      attr_reader :context

      def ensure_with_handler
        try(:ensure_callback)
      end
    end

    class_methods do
      def before_call(*filters, &block)
        set_callback(:call, :before, *filters, &block)
      end

      def after_call(*filters, &block)
        set_callback(:call, :after, *filters, &block)
      end

      def around_call(*filters, &block)
        set_callback(:call, :around, *filters, &block)
      end

      def ensure_call(&block)
        define_method(:ensure_callback) { instance_exec(&block) }
      end

      def set(**args)
        ConfiguredService.new(self, **args)
      end

      def call!(**args)
        Context.new(**args).tap { |context| new(context).run }
      end

      def call(**args)
        Context.new(**args).tap { |context| new(context).run }
      rescue Failure => error
        error.context
      end
    end
  end
end
