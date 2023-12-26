class User
  module Deactivatable
    extend ActiveSupport::Concern

    DEACTIVATION_BUFFER = 3.days

    included { scope :active, -> { where(deactivated_at: nil) } }

    def deactivated?
      deactivated_at.present?
    end

    def active? = !deactivated?

    def schedule_deactivation
      User::Deactivatable::DeactivationJob.set(wait_until: DEACTIVATION_BUFFER.from_now.noon).perform_later(
        id,
        updated_at
      )
    end

    def deactivate!
      touch(:deactivated_at)
    end

    class DeactivationJob < ApplicationJob
      discard_on ActiveRecord::RecordNotFound

      def perform(user_id, updated_at)
        ::User.find_by!(id: user_id, updated_at:).deactivate!
      end
    end
  end
end
