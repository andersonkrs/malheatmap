class User
  class ActivitiesGenerator
    def initialize(user)
      @user = user
      @processed_entries = ProcessedEntries.new
      @processed_activities = ProcessedActivities.new
    end

    def run
      user.with_time_zone do
        calculate_activities_per_day_from_history
        persist
      end
    end

    private

    attr_reader :user, :processed_entries, :processed_activities

    def calculate_activities_per_day_from_history
      entries = user
                  .entries
                  .eager_load(:item)
                  .order(:timestamp, :item_id, :amount, :created_at)

      entries.each do |entry|
        generate_activity_from_entry(entry)

        processed_entries << entry
      end
    end

    def generate_activity_from_entry(current_entry)
      date = current_entry.timestamp.to_date
      item = current_entry.item

      activity = processed_activities.find_or_create(item, date)

      # Some uses prefer to count their activities by entry line in their history
      # like other existing tools, MALGraph for example
      activity.amount += if user.count_each_entry_as_an_activity?
                           1
                         else
                           calculate_amount_from_last_entry_position(current_entry, item, date)
                         end
    end

    def calculate_amount_from_last_entry_position(current_entry, item, date)
      previous_entry = processed_entries.find_last_for(item, date)

      if previous_entry.blank?
        current_entry.amount
      else
        current_entry.amount - previous_entry.amount
      end
    end

    def persist
      ApplicationRecord.transaction do
        user.activities.delete_all

        processed_activities.each do |activity|
          user.activities << activity
        end
      end
    end
  end

  class ProcessedEntries
    def initialize
      @entries = {}
    end

    def <<(entry)
      entries[entry.item_id] ||= []
      entries[entry.item_id] << entry
    end

    def find_last_for(item, date)
      entries
        .fetch(item.id, [])
        .sort_by { |entry| [entry.timestamp, entry.amount, entry.created_at] }
        .find_all { |entry| entry.timestamp.to_date <= date }
        .last
    end

    private

    attr_reader :entries
  end

  class ProcessedActivities
    def initialize
      @activities = {}
    end

    def each(&block)
      activities.each_value do |activity|
        block.call(activity)
      end
    end

    def find_or_create(item, date)
      activities["#{item.id}/#{date}"] ||= Activity.new(item: item, date: date, amount: 0)
    end

    private

    attr_reader :activities
  end
end
