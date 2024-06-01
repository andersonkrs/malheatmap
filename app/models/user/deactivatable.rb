class User
  module Deactivatable
    extend ActiveSupport::Concern

    DEACTIVATION_BUFFER = 3.days

    included { scope :active, -> { where(deactivated_at: nil) } }

    def deactivated?
      deactivated_at.present?
    end

    def active? = !deactivated?

    def schedule_deactivation(reason:)
      User::Deactivatable::DeactivationJob.set(wait_until: DEACTIVATION_BUFFER.from_now.noon).perform_later(
        id,
        updated_at,
        reason,
      )
    end

    def deactivate!
      touch(:deactivated_at)
    end

    class DeactivationJob < ApplicationJob
      discard_on ActiveRecord::RecordNotFound

      def perform(user_id, updated_at, reason)
        ::User.find_by!(id: user_id, updated_at:).deactivate!
        Rails.logger.info "User #{user_id} deactivated for #{reason}"
      end
    end
  end
end
