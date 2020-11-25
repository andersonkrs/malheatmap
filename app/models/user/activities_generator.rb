class User
  class ActivitiesGenerator
    def initialize(user)
      @user = user
      @processed_entries = {}
      @processed_activities = {}
    end

    def run
      user.with_time_zone do
        generate_activities_per_day_from_history
        persist_activities
      end
    end

    private

    attr_reader :user, :processed_entries, :processed_activities

    def generate_activities_per_day_from_history
      entries = user
                  .entries
                  .eager_load(:item)
                  .order(:timestamp, :item_id, :amount, :created_at)

      entries.each do |entry|
        generate_activity_from_entry(entry)

        record_processed_entry(entry)
      end
    end

    def generate_activity_from_entry(current_entry)
      date = current_entry.timestamp.to_date
      item = current_entry.item

      activity = find_or_initialize_activity_by(date, item)
      previous_entry = find_previous_processed_entry(date, item) || current_entry

      calculate_activity_amount(activity, current_entry.amount, previous_entry.amount)
    end

    def find_previous_processed_entry(date, item)
      processed_entries
        .fetch(item.id, [])
        .sort_by { |entry| [entry.timestamp, entry.amount, entry.created_at] }
        .find_all { |entry| entry.timestamp.to_date <= date }
        .last
    end

    def find_or_initialize_activity_by(date, item)
      processed_activities["#{date}/#{item.id}"] ||= Activity.new(date: date, item: item, amount: 0)
    end

    def calculate_activity_amount(activity, current_amount, previous_amount)
      if current_amount != previous_amount
        activity.amount += current_amount - previous_amount
      else
        activity.amount = current_amount
      end
    end

    def record_processed_entry(entry)
      processed_entries[entry.item_id] ||= []
      processed_entries[entry.item_id] << entry
    end

    def persist_activities
      ActiveRecord::Base.transaction do
        user.activities.delete_all

        processed_activities.each_value do |activity|
          user.activities << activity
        end
      end
    end
  end
end
