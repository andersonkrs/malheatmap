require "mini_magick"

class User
  class SignatureGenerator
    include CalendarHelper

    def initialize(user)
      @user = user
    end

    def run
      user.with_time_zone do
        screenshot = HtmlScreenshot
                       .from(signature_html)
                       .crop(width: 824, height: 150)
                       .element(".signature")

        screenshot.take do |output|
          image = resize_to_mal_max_size(output)

          user.signature.attach(io: File.open(image.path), filename: "#{user.username}.png")
        end
      end
    end

    private

    SIGNATURE_MAX_SIZE = "600x150".freeze

    attr_reader :user

    def signature_html
      date_range = calculate_date_range_for_year(Time.zone.today.year)
      activities = user.activities.includes(:item).for_date_range(date_range).order(date: :desc)

      ApplicationController.render(
        "users/signature",
        locals: {
          date_range: date_range,
          activities: activities
        },
        layout: nil
      )
    end

    def resize_to_mal_max_size(screenshot)
      MiniMagick::Image.read(screenshot).tap do |image|
        image.resize(SIGNATURE_MAX_SIZE)
      end
    end
  end
end
