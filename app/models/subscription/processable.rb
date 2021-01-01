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
      response = try_crawl_user_data

      SubscriptionChannel.broadcast_to(self, response)
      update!(processed: true)
    end

    private

    def try_crawl_user_data
      user = User.create!(username: username)

      if user.crawl_mal_data
        { status: :success, redirect: user_path(user) }
      else
        user.destroy
        { status: :failure, notification: render_error_notification(user.errors[:base].first) }
      end
    rescue StandardError => error
      ErrorNotifier.notify(error)
      { status: :failure, redirect: internal_error_path }
    end

    def render_error_notification(message)
      ApplicationController.render NotificationComponent.new(message: message), layout: false
    end
  end
end
