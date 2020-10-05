class User
  class DetermineGeolocation < ApplicationService
    delegate :crawled_data, to: :context

    def call
      result = Geocoder.search(location)

      if result.present?
        geodata = result.first

        crawled_data[:profile].merge!(
          latitude: geodata.latitude,
          longitude: geodata.longitude,
          time_zone: time_zone_for(*geodata.coordinates)
        )
      end

      set_defaults
    end

    private

    def set_defaults
      crawled_data[:profile][:latitude] ||= nil
      crawled_data[:profile][:longitude] ||= nil
      crawled_data[:profile][:time_zone] ||= "UTC"
    end

    def location
      crawled_data.dig(:profile, :location)
    end

    def time_zone_for(lat, long)
      results = [WhereTZ.lookup(lat, long)].flatten.compact
      results.first
    end
  end
end
