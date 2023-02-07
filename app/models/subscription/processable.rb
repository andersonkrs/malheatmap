class Subscription
  module Processable
    extend ActiveSupport::Concern
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
        self.redirect_path = Rails.application.routes.url_helpers.user_path(user)
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

    def capture_and_redirect(error)
      self.redirect_path = Rails.application.routes.url_helpers.internal_error_path
      process_errors << error.message
      ErrorNotifier.capture(error)
    end

    def save_and_broadcast
      self.processed_at = Time.current
      save!(validate: false)

      redirect_path.present? ? broadcast_redirect : broadcast_new_form
    end

    def broadcast_redirect
      broadcast_redirect_to(path: redirect_path, action: :replace)
    end

    def broadcast_new_form
      broadcast_replace(partial: "subscriptions/form", locals: { subscription: Subscription.new(process_errors:) })
    end
  end
end
