require "test_helper"

class User::CalendarImageableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  setup { @user = users(:babyoda) }

  test "generates user calendar image correctly using current date" do
    travel_to Date.new(2020, 5, 1)

    @user.activities.create!(
      [
        { item: items(:bleach), amount: 6, date: Date.new(2020, 5, 1) },
        { item: items(:bleach), amount: 4, date: Date.new(2020, 4, 4) },
        { item: items(:bleach), amount: 3, date: Date.new(2020, 3, 14) },
        { item: items(:bleach), amount: 2, date: Date.new(2020, 2, 20) },
        { item: items(:bleach), amount: 1, date: Date.new(2020, 1, 1) },
        { item: items(:bleach), amount: 30, date: Date.new(2019, 12, 1) },
        { item: items(:bleach), amount: 20, date: Date.new(2019, 11, 15) },
        { item: items(:bleach), amount: 10, date: Date.new(2019, 10, 2) },
        { item: items(:bleach), amount: 9, date: Date.new(2019, 9, 12) },
        { item: items(:bleach), amount: 8, date: Date.new(2019, 8, 7) },
        { item: items(:bleach), amount: 7, date: Date.new(2019, 7, 26) },
        { item: items(:bleach), amount: 5, date: Date.new(2019, 6, 30) }
      ]
    )

    @user.calendar_images.generate

    perform_enqueued_jobs

    assert @user.calendar_image.attached?
    @user.calendar_image.blob.open do |file|
      assert_operator file.size, :>, 0.kilobytes
    end
  end

  test "enqueues calendar image generation when updating the user checksum" do
    @user.update!(checksum: "mynewone")

    assert_enqueued_jobs 1, only: User::CalendarImages::GenerateJob
    assert_enqueued_with job: User::CalendarImages::GenerateJob, args: [@user]
  end

  test "enqueues calendar image generation when updating the user and the image is obsolete" do
    @user.calendar_image.attach(file_fixture_upload("user_signature.png"))

    assert_enqueued_jobs 0, only: User::CalendarImages::GenerateJob

    travel_to 2.days.from_now

    @user.touch

    assert_enqueued_jobs 1, only: User::CalendarImages::GenerateJob
    assert_enqueued_with job: User::CalendarImages::GenerateJob, args: [@user]
  end
end
