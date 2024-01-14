require "image_processing/mini_magick"

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
        queue_as :default

        def perform(user)
          user.signature_image.generate
        end
      end

      private

      attr_reader :user

      def generate_from_activities
        calendar_html = render_calendar_html

        Tempfile.open(%w[signature .html]) do |html_file|
          html_file.write(calendar_html)

          capture_html_screenshot(html_file)
            .then { |screenshot| resize_to_mal_max_size(screenshot) }
            .then { |screenshot| user.signature.attach(io: screenshot, filename: "#{user.username}.png") }
        end
      end

      def render_calendar_html
        activities_amount_per_day = user.calendars.current_year.activities_amount_sum_per_day

        ApplicationController.render("users/signature", locals: { activities_amount_per_day: }, layout: nil)
      end

      def capture_html_screenshot(html_file)
        Tempfile.open(%w[screenshot .png]) do |screenshot_file|
          BrowserSession.instance.fetch_page do |page|
            page.go_to("file:#{html_file.path}")
            page.screenshot(selector: ".signature", path: screenshot_file.path, format: :png)
          end

          screenshot_file
        end
      end

      def resize_to_mal_max_size(screenshot_file)
        ImageProcessing::MiniMagick.source(screenshot_file).resize_to_limit(600, 150).call
      end
    end
  end
end
