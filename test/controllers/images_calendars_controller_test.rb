require "test_helper"

class Images::CalendarsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:babyoda)
  end

  test "returns not found instead of raising when no image was generated yet" do
    assert_not @user.calendar_image.attached?
    assert_not @user.signature.attached?

    assert_enqueued_with(job: User::CalendarImages::GenerateJob) do
      get "/users/#{@user.username}/images/calendar"
    end

    assert_response :not_found
  end

  test "redirects to the calendar image when attached" do
    @user.calendar_image.attach(
      io: StringIO.new("png"), filename: "calendar.png", content_type: "image/png"
    )

    get "/users/#{@user.username}/images/calendar"

    assert_response :redirect
  end
end
