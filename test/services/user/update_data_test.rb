require "test_helper"

class User
  class UpdateDataTest < ActiveSupport::TestCase
    test "updates user data when crawling is ok" do
      user = create(:user, username: "ManOfBalance")
      result = UpdateData.call(user: user)
      user.reload

      assert result.success?
      assert user.avatar_url.present?
      assert_equal 196, user.entries.count
      assert_equal 185, user.activities.count
      assert user.signature.attached?
    end

    test "returns failure when a crawling error occurs" do
      user = create(:user, username: "12m1o23zxzxzxedddk")
      result = UpdateData.call(user: user)

      assert result.failure?
      assert result.message.present?
    end
  end
end
