class User
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      has_many :access_tokens, inverse_of: :user, dependent: :delete_all do
        def replace_current!(**attributes)
          transaction(requires_new: true) do
            where(discarded_at: nil).update_all(discarded_at: Time.current)
            create!(**attributes)
          end
        end

        def current_token
          current&.token
        end

        def current
          where(discarded_at: nil).first
        end
      end
    end

    def mal_account_linked?
      mal_id.present?
    end

    def signed_in
      User::UpdateGeolocationJob.perform_later(self) if saved_change_to_location?
      User::SignedInJob.set(wait: 5.seconds).perform_later(self)
    end
  end
end
