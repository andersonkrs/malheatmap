class User
  class GenerateActivitiesFromHistory < ApplicationService
    delegate :user, to: :context

    before_call do
      @processed_entries = []
      @processed_activities = []
    end

    def call
      generate_activities_per_day
      persist_activities
    end

    private

    def generate_activities_per_day
      entries = user
                  .entries
                  .preload(:item)
                  .order(:timestamp, :item_id, :amount, :created_at)

      entries.each do |entry|
        generate_activity_from_entry(entry)

        @processed_entries << entry
      end
    end

    def generate_activity_from_entry(entry)
      date = entry.timestamp.to_date
      item = entry.item

      activity = find_or_initialize_activity(date, item)
      last_entry = find_last_processed_entry(date, item) || entry

      calculate_activity_amount(activity, entry.amount, last_entry.amount)
    end

    def persist_activities
      ActiveRecord::Base.transaction do
        user.activities.delete_all
        @processed_activities.each do |activity|
          user.activities << activity
        end
      end
    end

    def find_last_processed_entry(date, item)
      @processed_entries
        .sort_by { |entry| [entry.timestamp, entry.created_at] }
        .find_all { |entry| entry.timestamp.to_date <= date && entry.item.id == item.id }
        .last
    end

    def find_or_initialize_activity(date, item)
      current_activity = @processed_activities.find do |activity|
        activity.date == date && activity.item.id == item.id
      end

      if current_activity.blank?
        current_activity = Activity.new(date: date, item: item, amount: 0)
        @processed_activities << current_activity
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
