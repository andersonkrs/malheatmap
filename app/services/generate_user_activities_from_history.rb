class GenerateUserActivitiesFromHistory < ApplicationService
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
    entries = user.entries.order(:timestamp, :item_id, :created_at)

    entries.each do |entry|
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

  def persist_activities
    ActiveRecord::Base.transaction do
      user.activities.delete_all
      @processed_activities.each(&:save!)
    end
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
    current_activity = @processed_activities.find do |activity|
      activity.date == date && activity.item_id == item_id
    end

    if current_activity.blank?
      current_activity = Activity.new(user_id: user.id, date: date, item_id: item_id, amount: 0)
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
