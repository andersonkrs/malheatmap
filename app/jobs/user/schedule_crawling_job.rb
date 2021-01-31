class User
  class ScheduleCrawlingJob < ApplicationJob
    queue_as :default

    def perform
      users = users_which_have_not_been_updated(at_least: 12.hours.ago)

      users.each(&:crawl_mal_data_later)
    end

    private

    def users_which_have_not_been_updated(at_least:)
      User
        .where("updated_at <= ?", at_least)
        .order(:updated_at)
        .limit(50)
        .shuffle
    end
  end
end
