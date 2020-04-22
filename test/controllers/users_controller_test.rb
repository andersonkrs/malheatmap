require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "returns success when gets show" do
    user = create(:user)
    create_list(:activity, 6, user: user)

    get user_url(user)

    assert_response :success
  end
end
