require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "returns success when get show" do
    user = create(:user)
    create_list(:entry, 6, user: user)

    get user_url(user)

    assert_response :success
  end
end
