require "test_helper"

class User
  class UpdateDataTest < ActiveSupport::TestCase
    include VCRCassettes

    setup do
      @user = create(:user, username: "ManOfBalance")
      @service = UpdateData.set(user: @user)

      Geocoder::Lookup::Test.add_stub("Bandung, West Java, Indonesia",
                                      [{ coordinates: [-6.9344694, 107.6049539] }])
    end

    test "updates user data when crawling is ok" do
      result = @service.call
      @user.reload

      assert result.success?
      assert @user.avatar_url.present?
      assert @user.location.present?
      assert @user.time_zone.present?
      assert @user.latitude.present?
      assert @user.longitude.present?
      assert_equal 196, @user.entries.count
      assert_equal 185, @user.activities.count
      assert @user.signature.attached?
    end

    test "does not update user's data when checksum did not change" do
      OpenSSL::Digest::MD5.stub(:hexdigest, @user.checksum) do
        assert_no_changes -> { @user.attributes.except("updated_at") } do
          @service.call!
          @user.reload
        end

        assert_equal 0, @user.activities.count
        assert_equal 0, @user.activities.entries.count
      end
    end

    test "does not update user location if it did not change" do
      @user.update!(location: "Bandung, West Java, Indonesia")

      assert_no_changes -> { @user.attributes.slice(:latitude, :longitude, :time_zone) } do
        @service.call
        @user.reload
      end
    end

    test "updates user updated at even if the checksum dit not change" do
      OpenSSL::Digest::MD5.stub(:hexdigest, @user.checksum) do
        assert_changes -> { @user.updated_at } do
          @service.call!
          @user.reload
        end
      end
    end

    test "generates signature even if the checksum did not change" do
      OpenSSL::Digest::MD5.stub(:hexdigest, @user.checksum) do
        assert_changes -> { @user.signature.attached? }, from: false, to: true do
          @service.call!
          @user.reload
        end
      end
    end

    test "returns failure when a crawling error occurs" do
      user = create(:user, username: "12m1o23zxzxzxedddk")
      result = @service.call(user: user)

      assert result.failure?
      assert result.message.present?
    end
  end
end
