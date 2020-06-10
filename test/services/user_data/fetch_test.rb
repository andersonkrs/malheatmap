require "test_helper"

module UserData
  class FetchTest < ActiveSupport::TestCase
    test "updates user data when crawling is ok" do
      user = create(:user, username: "ManOfBalance")
      result = UserData::Fetch.call(user: user)

      assert result.success?
      assert user.avatar_url.present?
      assert_equal 192, user.entries.count
      assert_equal 181, user.activities.count
    end

    test "returns failure when a crawling error occurs" do
      user = create(:user, username: "12m1o23zxzxzxedddk")
      result = UserData::Fetch.call(user: user)

      assert result.failure?
      assert result.message.present?
    end
  end
end
