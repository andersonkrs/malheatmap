class User
  module Authenticatable
    extend ActiveSupport::Concern

    def signed_in
      User::UpdateGeolocationJob.perform_later(self) if saved_change_to_location?
      User::SignedInJob.set(wait: 5.seconds).perform_later(self)
    end
  end
end
