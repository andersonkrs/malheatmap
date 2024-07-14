require "image_processing/vips"

class User
  module Signaturable
    class SignatureImage
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
        User::Signaturable::SignatureImage::GenerateJob.perform_later(user)
      end

      def obsolete?
        return true unless user.signature.attached?
        return true if user.saved_change_to_checksum?

        user.signature.blob.created_at.in_time_zone.to_date != Time.zone.today
      end

      class GenerateJob < ApplicationJob
        retry_on(*BrowserSession::RETRYABLE_ERRORS, attempts: 10, wait: :polynomially_longer)

        limits_concurrency to: 1, key: :screenshots, duration: 2.hours

        queue_as :screenshots

        def perform(user)
          user.signature_image.generate
        end
      end

      private

      attr_reader :user

      def generate_from_activities
        calendar_html = render_calendar_html

        capture_html_screenshot(calendar_html)
          .then { |screenshot| resize_to_mal_max_size(screenshot) }
          .then { |screenshot| user.signature.attach(io: screenshot, filename: "#{user.username}.png") }
      end

      def render_calendar_html
        activities_amount_per_day = user.calendars.current_year.activities_amount_sum_per_day

        ApplicationController.render("users/signature", locals: { activities_amount_per_day: }, layout: nil)
      end

      def capture_html_screenshot(html_page)
        png_image = nil

        BrowserSession.fetch_page do |page|
          page.go_to("data:text/html;base64,#{Base64.strict_encode64(html_page)}")

          png_image = page
            .screenshot(selector: ".signature", format: :png, encoding: :binary)
            .then { Vips::Image.new_from_buffer(_1, "") }
        end

        png_image
      end

      def resize_to_mal_max_size(screenshot_file)
        Rails.logger.info("Resizing screenshot with libvips")
        ImageProcessing::Vips
          .source(screenshot_file)
          .saver(quality: 100)
          .resize_to_limit(600, 150)
          .call
      end
    end
  end
end
