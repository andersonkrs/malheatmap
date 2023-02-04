# frozen_string_literal: true

module Turbo
  module Broadcastable
    include Turbo::Streams::ActionHelper

    def broadcast_redirect_to(path:, action: :advance)
      Turbo::StreamsChannel.broadcast_redirect_to(self, path:, action:)
    end
  end
end

module Turbo
  module Streams
    module Broadcasts
      def broadcast_redirect_to(*streamables, path:, action: :advance)
        broadcast_stream_to(
          *streamables,
          content: turbo_stream_action_tag(:redirect, :target => "body", :path => path, "turbo-action" => action)
        )
      end
    end
  end
end
