# frozen_string_literal: true

module Turbo
  module Broadcastable
    def broadcast_redirect_to(path:, action: :advance)
      Turbo::StreamsChannel.broadcast_stream_to(
        self,
        content: turbo_stream_action_tag(:redirect, :target => "body", :path => path, "turbo-action" => action)
      )
    end
  end
end
