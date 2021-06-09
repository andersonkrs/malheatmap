class Subscription
  module Processable
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    included do
      scope :processed, -> { where.not(processed_at: nil) }
      scope :pending, -> { where(processed_at: nil) }
    end

    def processed?
      processed_at.present?
    end

    def submitted
      Subscription::ProcessJob.enqueue(self) unless processed?
    end

    def processed
      user = User.create_or_find_by!(username: username)

      response = if user.crawl_data
                   { status: :success, redirect: user_path(user) }
                 else
                   user.destroy!
                   { status: :failure, notification: render_error_notification(user.errors[:base].first) }
                 end

      SubscriptionChannel.broadcast_to(self, response)
    rescue StandardError => error
      user&.destroy
      SubscriptionChannel.broadcast_to(self, status: :failure, redirect: internal_error_path)
      ErrorNotifier.capture(error)
    ensure
      update!(processed_at: Time.current)
    end

    private

    def render_error_notification(message)
      ApplicationController.render NotificationComponent.new(message: message), layout: false
    end
  end
end
