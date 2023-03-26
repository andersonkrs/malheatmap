class User::UpdateGeolocationJob < ApplicationJob
  queue_as :default

  def perform(user)
    Rails.logger.info("User without location: #{user.username}") and return if user.location.blank?

    result = Geocoder.search(user.location)
    coordinates = result&.first&.coordinates

    return if coordinates.blank?

    user.latitude, user.longitude = *coordinates
    user.save!(validate: false)
  end
end
