require "image_processing/mini_magick"

class User
  module Signaturable
    class SignatureImage
      def initialize(user)
        super()
        @user = user
      end

      def generate
        user.with_time_zone do
          generate_from_activities
        end
      end

      def obsolete?
        return true unless user.signature.attached?

        user.signature.blob.created_at.in_time_zone.to_date != Time.zone.today
      end

      private

      attr_reader :user

      def generate_from_activities
        calendar_html = render_calendar_html

        html_file = Tempfile.new(%w[signature .html])
        html_file.write(calendar_html)
        html_file.close

        screenshot_file = capture_html_screenshot(html_file)
        screenshot_file = resize_to_mal_max_size(screenshot_file)

        user.signature.attach(io: screenshot_file, filename: "#{user.username}.png")
      end

      def render_calendar_html
        activities_amount_per_day = user.calendars[Time.current.year].activities_amount_sum_per_day

        ApplicationController.render(
          "users/signature",
          locals: { activities_amount_per_day: activities_amount_per_day },
          layout: nil
        )
      end

      def capture_html_screenshot(html_file)
        Tempfile.open(%w[screenshot .png]) do |screenshot_file|
          with_retries exception_class: Ferrum::Error do
            browser = Ferrum::Browser.new(
              headless: true,
              browser_options: {
                "no-sandbox": nil,
                "disable-setuid-sandbox": nil
              },
              timeout: 30,
              process_timeout: 30
            )
            browser.go_to("file:#{html_file.path}")
            browser.screenshot(selector: ".signature", path: screenshot_file.path, format: :png)
          ensure
            browser.quit
          end

          screenshot_file
        end
      end

      def resize_to_mal_max_size(screenshot_file)
        ImageProcessing::MiniMagick
          .source(screenshot_file)
          .resize_to_limit(600, 150)
          .call
      end

      def with_retries(exception_class:)
        attempts = 0
        begin
          yield
        rescue StandardError => error
          raise error if !error.is_a?(exception_class) || attempts == 3

          sleep(1)
          attempts += 1
          retry
        end
      end
    end
  end
end
