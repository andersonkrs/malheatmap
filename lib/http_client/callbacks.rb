module HttpClient
  module Callbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :request, skip_after_callbacks_if_terminated: true
    end

    module ClassMethods
      # Defines a callback that will get called right before the request is performed
      def before_request(*filters, &blk)
        set_callback(:request, :before, *filters, &blk)
      end

      # Defines a callback that will get called right after the request is performed
      def after_request(*filters, &blk)
        set_callback(:request, :after, *filters, &blk)
      end

      # Defines a callback that will get called around the request is performed
      def around_request(*filters, &blk)
        set_callback(:request, :around, *filters, &blk)
      end
    end
  end
end
