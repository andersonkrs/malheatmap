require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "returns success when get index" do
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

    assert_response :accepted
    assert_equal "text/javascript", @response.media_type
    assert_equal 1, Subscription.count

    created_subscription = Subscription.find_by(username: username)
    assert_enqueued_jobs 2
    assert_enqueued_with job: Subscription::ProcessJob, args: [created_subscription]
    assert_enqueued_with job: Purgeable::PurgeRecordJob, args: [created_subscription]
  end

  test "does not enqueue anything when creating invalid subscription" do
    post subscriptions_url, params: {
      subscription: {
        username: "12l,3l123./"
      }
    }, xhr: true

    assert_response :unprocessable_entity
    assert_equal "text/javascript", @response.media_type
    assert_equal 0, Subscription.count
    assert_no_enqueued_jobs
  end

  test "redirects to user profile when it is already subscribed" do
    user = users(:babyoda)

    post subscriptions_url, params: {
      subscription: {
        username: user.username
      }
    }

    assert_redirected_to user_path(user)
    assert_equal 0, Subscription.count
    assert_no_enqueued_jobs
  end

  test "should ignore username case and redirects to user profile" do
    user = users(:babyoda)

    post subscriptions_url, params: {
      subscription: {
        username: user.username.titleize
      }
    }

    assert_redirected_to user_path(user.username.titleize)
    assert_equal 0, Subscription.count
    assert_no_enqueued_jobs
  end
end
