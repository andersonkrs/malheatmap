class User
  module Geolocatable
    extend ActiveSupport::Concern

    included do
      geocoded_by :location

      after_create_commit :geocode_async
      after_update_commit :geocode_async, if: :saved_change_to_location?
    end

    def geocode_async
      FetchGeolocationJob.perform_later(self)
    end

    class FetchGeolocationJob < ApplicationJob
      def perform(user)
        user.geocode
        user.save!(validate: false)
      end
    end
  end
end
