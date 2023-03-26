class User::SignedInJob < ApplicationJob
  queue_as :default

  def perform(user)
    user.crawl_data(update_profile: false)

    user.broadcast_replace(
      partial: "users/activities",
      locals: {
        user:,
        calendar: user.calendars.current,
        selected_year: user.calendars.current.year
      }
    )
  end
end
