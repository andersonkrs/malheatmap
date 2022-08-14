class Subscription
  module Processable
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers
    include ActionView::RecordIdentifier

    included do
      scope :processed, -> { where.not(processed_at: nil) }
      scope :pending, -> { where(processed_at: nil) }
    end

    def pending?
      !processed?
    end

    def processed?
      processed_at.present?
    end

    def submitted
      Subscription::ProcessJob.enqueue(self) unless processed?
    end

    def processed
      user = User.create_or_find_by!(username: username)

      crawled = user.crawl_data

      if crawled
        self.redirect_path = user_path(user)
      else
        user.destroy!
        self.errors.add(:base, user.errors[:base].first)
      end
    rescue StandardError => error
      self.redirect_path = internal_error_path
      user&.destroy
      ErrorNotifier.capture(error)
    ensure
      self.processed_at = Time.current
      save!(validate: false)

      broadcast_replace(partial: "subscriptions/subscription", target: dom_id(self), locals: { subscription: self })
    end
  end
end
