class GenerateUserSignature < ApplicationService
  delegate :user, to: :context

  before_call do
    Rails.logger.info "Generating signature for user: #{user.username}"

    @tempfile = File.open(Rails.root.join("tmp/#{user.id}.html"), "w+")
  end

  def call
    @tempfile.write(signature_html)

    screenshot = HtmlScreenshot
                   .source(@tempfile)
                   .crop(width: 824, height: 150)
                   .selector(".signature")

    screenshot.take do |file|
      user.signature.attach(io: file, filename: "#{user.username}.png")
    end
  end

  ensure_call do
    File.delete(@tempfile)
  end

  private

  def signature_html
    date_range = Graph::CalculateDateRange.call(year: Time.zone.today.year).range
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
end
