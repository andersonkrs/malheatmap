require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "returns success when get index" do
    create_list(:user, 3)

    get subscriptions_url

    assert_response :success
    assert_select "p", "3 subscribed users!"
  end

  test "enqueues the job when creating a valid subscription" do
    username = "mysuperuser"

    post subscriptions_url, params: {
      subscription: {
        username: username
      }
    }, xhr: true

    assert_equal "text/javascript", @response.media_type
    assert_equal 1, Subscription.count
    assert_enqueued_jobs 1, only: Subscription::ProcessJob, queue: :default
  end

  test "does not enqueue anything when creating invalid subscription" do
    post subscriptions_url, params: {
      subscription: {
        username: "12l,3l123./"
      }
    }, xhr: true

    assert_equal "text/javascript", @response.media_type
    assert_no_enqueued_jobs
  end

  test "redirects to user profile when it is already subscribed" do
    user = create(:user)

    post subscriptions_url, params: {
      subscription: {
        username: user.username
      }
    }

    assert_redirected_to user_path(user)
    assert_no_enqueued_jobs
    assert_equal 0, Subscription.count
  end
end
