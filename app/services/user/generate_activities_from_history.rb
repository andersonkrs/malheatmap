class User
  class GenerateActivitiesFromHistory < ApplicationService
    delegate :user, to: :context

    before_call do
      @processed_entries = []
      @processed_activities = []
    end

    around_call :switch_to_user_time_zone

    def call
      generate_activities_per_day
      persist_activities
    end

    private

    def switch_to_user_time_zone(&block)
      Time.use_zone(user.time_zone) { block.call }
    end

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

    def generate_activity_from_entry(current_entry)
      date = current_entry.timestamp.to_date
      item = current_entry.item

      activity = find_or_initialize_activity(date, item)
      previous_entry = find_previous_processed_entry(date, item) || current_entry

      calculate_activity_amount(activity, current_entry.amount, previous_entry.amount)
    end

    def persist_activities
      activities_data = @processed_activities.map { |activity| activity.attributes.compact }

      ActiveRecord::Base.transaction do
        user.activities.delete_all
        Activity.insert_all!(activities_data) if activities_data.present?
      end
    end

    def find_previous_processed_entry(date, item)
      @processed_entries
        .sort_by { |entry| [entry.timestamp, entry.amount, entry.created_at] }
        .find_all { |entry| entry.timestamp.to_date <= date && entry.item.id == item.id }
        .last
    end

    def find_or_initialize_activity(date, item)
      current_activity = @processed_activities.find do |activity|
        activity.date == date && activity.item.id == item.id
      end

      if current_activity.blank?
        current_activity = Activity.new(user: user, date: date, item: item, amount: 0)
        @processed_activities << current_activity
      end

      current_activity
    end

    def calculate_activity_amount(activity, current_amount, previous_amount)
      if current_amount != previous_amount
        activity.amount += current_amount - previous_amount
      else
        activity.amount = current_amount
      end
    end
  end
end
