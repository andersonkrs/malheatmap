require "mini_magick"

class User
  class GenerateSignature < ApplicationService
    delegate :user, to: :context

    before_call do
      Rails.logger.info("Generating signature for user: #{user}")
    end

    around_call do |block|
      Tempfile.create(%w[signature .html], Rails.root.join("tmp")) do |tempfile|
        @tempfile = tempfile
        block.call
      end
    end

    def call
      @tempfile.write(signature_html)

      screenshot = HtmlScreenshot
                     .from(@tempfile.path)
                     .crop(width: 824, height: 150)
                     .element(".signature")

      screenshot.take do |output|
        resize_and_upload(output)
      end
    end

    private

    def signature_html
      date_range = Calendar::CalculateDateRange.call(year: Time.zone.today.year).range
      activities = user.activities.for_date_range(date_range).order(date: :desc)

      ApplicationController.render(
        "users/signature",
        locals: {
          date_range: date_range,
          activities: activities
        },
        layout: nil
      )
    end

    def resize_and_upload(screenshot)
      image = MiniMagick::Image.read(screenshot)
      image.resize(MAL::SIGNATURE_MAX_SIZE)

      user.signature.attach(io: File.open(image.path), filename: "#{user.username}.png")
    end
  end
end
