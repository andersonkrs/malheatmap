module Patterns
  class Service
    include ActiveSupport::Callbacks

    class Failure < StandardError
      attr_reader :context

      def initialize(context)
        @context = context
      end
    end

    define_callbacks :call

    def self.before_call(&block)
      set_callback(:call, :before, &block)
    end

    def self.after_call(&block)
      set_callback(:call, :after, &block)
    end

    def self.set(**args)
      ConfiguredService.new(self, **args)
    end

    def self.call!(**args)
      new(Context.new(**args)).run
    end

    def self.call(**args)
      Context.new(**args).tap do |context|
        new(context).run
      end
    rescue Failure => error
      error.context
    end

    def initialize(context)
      @context = context
    end

    def run
      run_callbacks :call do
        call
      end
    rescue StandardError
      rollback
      raise
    end

    def rollback; end

    private

    attr_reader :context

    class Context < OpenStruct
      def merge(context)
        current_hash = to_h
        incomming_hash = context.to_h

        self.class.new(current_hash.merge(incomming_hash))
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
  end
end
