require "test_helper"

class User
  class DetermineGeolocationTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)

      @data = {
        profile: {
          location: "Sorocaba, Brazil"
        }
      }

      @service = DetermineGeolocation.set(user: @user, crawled_data: @data)
    end

    test "fetches user latitude, longitude and time zone when user has a valid location" do
      Geocoder::Lookup::Test.add_stub("Sorocaba, Brazil", [{ coordinates: [-23.4961296, -47.4542266] }])

      result = @service.call!

      assert_equal "America/Sao_Paulo", result.crawled_data[:profile][:time_zone]
    end

    test "does not set geo location info and uses UTC as time zone when user has invalid location" do
      @data[:profile][:location] = "Death Star"
      Geocoder::Lookup::Test.add_stub("Death Star", [])

      result = @service.call!
      profile_data = result.crawled_data[:profile]

      assert_equal "UTC", profile_data[:time_zone]
      assert_nil profile_data[:latitude]
      assert_nil profile_data[:longitude]
    end
  end
end
