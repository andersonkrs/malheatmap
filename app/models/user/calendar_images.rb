require "image_processing/vips"

class User::CalendarImages
  def initialize(user)
    super()
    @user = user
  end

  def generate
    Instrumentation.instrument(title: "#{self.class.name}#generate") do
      user.with_time_zone { generate_from_activities }
    end
  end

  def generate_later
    User::CalendarImages::GenerateJob.perform_later(user)
  end

  def obsolete?
    return true unless user.calendar_image.attached?
    return true if user.saved_change_to_checksum?

    user.calendar_image.blob.created_at.in_time_zone.to_date != Time.zone.today
  end

  class GenerateJob < ApplicationJob
    retry_on(*BrowserSession::RETRYABLE_ERRORS, attempts: 10, wait: :polynomially_longer)

    limits_concurrency to: 2, key: :screenshots, duration: 2.hours

    queue_as :within_3_minutes

    def perform(user)
      user.calendar_images.generate
    end
  end

  private

  attr_reader :user

  def generate_from_activities
    calendar_html = render_calendar_html

    capture_html_screenshot(calendar_html)
  end

  def render_calendar_html
    calendar = user.calendars.current

    ApplicationController.render(
      "users/signature",
      locals: { activities_amount_per_day: calendar.activities_amount_sum_per_day },
      layout: nil
    )
  end

  def capture_html_screenshot(html_page)
    BrowserSession.fetch_page do |page|
      page.go_to("data:text/html;base64,#{Base64.strict_encode64(html_page)}")

      image = page
        .screenshot(
          encoding: :binary,
          selector: ".signature",
          format: :png,
          background_color: Ferrum::RGBA.new(0, 0, 0, 0.0)
        )

      user.calendar_image.attach(
        io: StringIO.new(image),
        filename: "#{user.username}_calendar.png",
        content_type: "application/png"
      )
    end
  end
end
