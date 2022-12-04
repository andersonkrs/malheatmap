class User
  class ActivitiesGenerator
    def initialize(user)
      super()
      @user = user
      @processed_entries = ProcessedEntries.new
      @processed_activities = ProcessedActivities.new(user)
    end

    def run
      Instrumentation.instrument(title: "#{self.class.name}#run") do
        user.with_time_zone do
          calculate_activities_per_day_from_history
          processed_activities.save!
        end
      end

      true
    end

    private

    attr_reader :user, :processed_entries, :processed_activities

    def calculate_activities_per_day_from_history
      entries = user.entries.order(:timestamp, :item_id, :amount, :created_at)

      entries.each do |entry|
        generate_activity_from_entry(entry)

        processed_entries << entry
      end
    end

    def generate_activity_from_entry(current_entry)
      item = current_entry.item
      date = current_entry.timestamp.in_time_zone.to_date

      activity = processed_activities.find_or_new(item, date)

      # Some uses prefer to count their activities by entry line in their history
      # like other existing tools, MALGraph for example
      activity.amount +=
        (user.count_each_entry_as_an_activity? ? 1 : calculate_amount_from_last_entry_position(current_entry))
    end

    def calculate_amount_from_last_entry_position(current_entry)
      last_amount = processed_entries.last_amount(current_entry)

      if last_amount.blank?
        current_entry.amount
      elsif current_entry.amount < last_amount
        1
      else
        current_entry.amount - last_amount
      end
    end

    class ProcessedActivities
      def initialize(user)
        super()
        @user = user
        @activities = {}
      end

      def find_or_new(item, date)
        activities["#{item.id}:#{date}"] ||= user.activities.build(item:, date:, amount: 0)
      end

      def save!
        user.activities.transaction do
          user.activities.delete_all

          activities.each_value(&:save!)
        end
      end

      private

      attr_reader :user, :activities
    end

    class ProcessedEntries
      attr_reader :entries

      def initialize
        super()
        @entries = {}
      end

      def <<(entry)
        entries[entry.item_id] = entry.amount
      end

      def last_amount(entry)
        entries[entry.item_id]
      end
    end
  end
end
