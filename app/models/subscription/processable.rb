class Subscription
  module Processable
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    included do
      after_commit :process_later, on: :create
    end

    def process_later
      Subscription::ProcessJob.enqueue(self)
    end

    def process!
      user = User.create!(username: username)

      if user.crawl_mal_data
        response = { status: :success, redirect: user_path(user) }
      else
        user.destroy
        response = { status: :failure, notification: render_error_notification(user.errors[:base].first) }
      end

      SubscriptionChannel.broadcast_to(self, response)
    rescue StandardError
      SubscriptionChannel.broadcast_to(self, status: :failure, redirect: internal_error_path)
      raise
    ensure
      update!(processed: true)
    end

    private

    def render_error_notification(message)
      ApplicationController.render NotificationComponent.new(message: message), layout: false
    end
  end
end
