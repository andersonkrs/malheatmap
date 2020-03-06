require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "returns success when get index" do
    get subscriptions_url

    assert_response :success
  end

  test "returns accepted status and enqueue the job when creating a new subscription" do
    username = "mysuperuser"

    post subscriptions_url, params: {
      subscription: {
        username: username
      }
    }

    subscription = Subscription.find_by(username: username)
    assert subscription.pending?

    assert_response :accepted
    assert_equal response.headers["ProcessID"], subscription.id
  end

  test "redirects to user profile when it is already subscribed" do
    user = create(:user)

    post subscriptions_url, params: {
      subscription: {
        username: user.username
      }
    }

    assert_redirected_to user_path(user)
  end

  test "returns flash error when submiting invalid username" do
    post subscriptions_url, params: {
      subscription: {
        username: "12l,3l123./"
      }
    }

    assert_response :bad_request
    assert_equal "Username is invalid", flash[:error]
  end
end
