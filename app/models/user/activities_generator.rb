class User
  class ActivitiesGenerator
    def initialize(user)
      super()
      @user = user
      @processed_entries = ProcessedEntries.new
      @processed_activities = ProcessedActivities.new
    end

    def run
      user.with_time_zone do
        calculate_activities_per_day_from_history
        save
      end
    end

    private

    attr_reader :user, :processed_entries, :processed_activities

    def calculate_activities_per_day_from_history
      entries = user
                  .entries
                  .order(:timestamp, :item_id, :amount, :created_at)

      entries.each do |entry|
        generate_activity_from_entry(entry)

        processed_entries << entry
      end
    end

    def generate_activity_from_entry(current_entry)
      date = current_entry.timestamp.in_time_zone.to_date
      item = current_entry.item

      activity = processed_activities.find_or_new(item, date)

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

    def save
      user.transaction do
        user.activities.delete_all
        activities_data = processed_activities.as_attributes_array("item_id", "amount", "date")

        user.activities.insert_all(activities_data) if activities_data.any?
      end
    end

    class ProcessedEntries
      def initialize
        @entries = {}
      end

      def <<(entry)
        entries["#{entry.mal_id}/#{entry.kind}"] ||= []
        entries["#{entry.mal_id}/#{entry.kind}"] << entry
      end

      def find_last_for(item, date)
        entries
          .fetch("#{item.mal_id}/#{item.kind}", [])
          .sort_by { |entry| [entry.timestamp, entry.amount] }
          .find_all { |entry| entry.timestamp.in_time_zone.to_date <= date }
          .last
      end

      private

      attr_reader :entries
    end

    class ProcessedActivities
      def initialize
        @activities = {}
      end

      def find_or_new(item, date)
        activities["#{item.mal_id}/#{item.kind}/#{date}"] ||= Activity.new(item: item, date: date, amount: 0)
      end

      def to_a
        activities.values.flatten
      end

      def as_attributes_array(*attrs)
        to_a.map { |activity| activity.attributes.extract!(*attrs) }
      end

      private

      attr_reader :activities
    end
  end
end
