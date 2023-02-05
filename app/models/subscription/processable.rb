class Subscription
  module Processable
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers
    include ActionView::RecordIdentifier

    included do
      scope :processed, -> { where.not(processed_at: nil) }
      scope :pending, -> { where(processed_at: nil) }
    end

    def processing?
      !processed?
    end

    def processed?
      processed_at.present?
    end

    def submitted
      Subscription::ProcessJob.enqueue(self) unless processed?
    end

    def processed
      user = User.create_or_find_by!(username:)
      self.process_errors = []

      crawled = user.crawl_data

      if crawled
        self.redirect_path = user_path(user)
      else
        user.destroy!
        self.process_errors = user.errors[:base]
      end
    rescue StandardError => error
      user&.destroy
      capture_and_redirect(error)
    ensure
      save_and_broadcast
    end

    private

    def render_error_notification(message)
      ApplicationController.render NotificationComponent.new(message:), layout: false
    end
  end
end
