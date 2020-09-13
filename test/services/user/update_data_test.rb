require "test_helper"

class User
  class UpdateDataTest < ActiveSupport::TestCase
    include VCRCassettes

    setup do
      @service = UpdateData
    end

    test "updates user data when crawling is ok" do
      user = create(:user, username: "ManOfBalance")
      result = @service.call(user: user)
      user.reload

      assert result.success?
      assert user.avatar_url.present?
      assert_equal 196, user.entries.count
      assert_equal 185, user.activities.count
      assert user.signature.attached?
    end

    test "does not update user's data when checksum did not change" do
      user = create_user_with_unmodified_checksum

      assert_no_changes -> { user.avatar_url } do
        @service.call!(user: user)
        user.reload
      end
      assert_equal 0, user.activities.count
      assert_equal 0, user.activities.entries.count
    end

    test "generates signature even if the checksum did not change" do
      user = create_user_with_unmodified_checksum

      assert_changes -> { user.signature.attached? }, from: false, to: true do
        @service.call!(user: user)
        user.reload
      end
    end

    test "returns failure when a crawling error occurs" do
      user = create(:user, username: "12m1o23zxzxzxedddk")
      result = @service.call(user: user)

      assert result.failure?
      assert result.message.present?
    end

    private

    def create_user_with_unmodified_checksum
      create(:user, username: "ManOfBalance", checksum: "4a9a0b4b40bde7c43b149765617776b9")
    end
  end
end
