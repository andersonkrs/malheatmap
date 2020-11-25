class User
  module GeneratableActivities
    extend ActiveSupport::Concern

    included do
      set_callback :crawl, :after, :generate_activities, if: :saved_change_to_checksum?
    end

    def generate_activities
      ActivitiesGenerator.new(self).run
    end
  end
end
