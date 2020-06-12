module UserData
  class GenerateActivitiesFromHistory < ApplicationService
    delegate :user, to: :context

    before do
      @processed_entries = []
      @processed_activites = []
    end

    def call
      generate_activities_per_day
      update_user_activities
    end

    private

    def generate_activities_per_day
      all_user_entries.each do |entry|
        generate_activity_from_entry(entry)

        @processed_entries << entry
      end
    end

    def generate_activity_from_entry(entry)
      date = entry.timestamp.to_date
      item_id = entry.item_id

      activity = find_or_initialize_activity(date, item_id)
      last_entry = find_last_processed_entry(date, item_id) || entry

      calculate_activity_amount(activity, entry.amount, last_entry.amount)
    end

    def update_user_activities
      ActiveRecord::Base.transaction do
        user.activities.delete_all
        @processed_activites.each(&:save!)
      end
    end

    def all_user_entries
      user
        .entries
        .order(:timestamp, :item_id, :created_at)
        .all
    end

    # :reek:DuplicateMethodCall
    # :reek:FeatureEnvy
    def find_last_processed_entry(date, item_id)
      @processed_entries
        .sort_by { |entry| [entry.timestamp, entry.created_at] }
        .find_all { |entry| entry.timestamp.to_date <= date && entry.item_id == item_id }
        .last
    end

    def find_or_initialize_activity(date, item_id)
      current_activity = @processed_activites.find do |activity|
        activity.date == date && activity.item_id == item_id
      end

      if current_activity.blank?
        current_activity = Activity.new(user_id: user.id, date: date, item_id: item_id, amount: 0)
        @processed_activites << current_activity
      end

      current_activity
    end

    def calculate_activity_amount(activity, current_amount, last_amount)
      if current_amount != last_amount
        activity.amount += current_amount - last_amount
      else
        activity.amount = current_amount
      end
    end
  end
end
