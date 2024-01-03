class User::MALSyncable::ScrapedData
  def initialize(user:, raw_data:)
    @user = user
    @raw_data = raw_data
    super()
  end

  def checksum
    @checksum ||= OpenSSL::Digest::MD5.hexdigest(Marshal.dump(raw_data))
  end

  def process!
    Instrumentation.instrument(title: "#{self.class.name}#process!") do
      return if user.checksum == checksum

      update_history(raw_data["history"])
      user.assign_attributes(**raw_data["profile"]) unless user.mal_account_linked?

      user.activities.generate_from_history
      user.checksum = checksum
    end
  end

  private

  attr_reader :raw_data, :user

  class DeletingOldHistoryNotAllowed < StandardError
  end

  def update_history(new_history_entries)
    return if new_history_entries.empty?

    cached_items = {}

    new_entries =
      new_history_entries.map do |entry_data|
        history_entry = Entry.new(amount: entry_data["amount"], timestamp: entry_data["timestamp"])
        history_entry.user_id = user.id
        history_entry.item = fetch_item(cached_items, mal_id: entry_data["item_id"], kind: entry_data["item_kind"])
        history_entry.item.name = entry_data["item_name"]
        history_entry
      end

    ApplicationRecord.transaction do
      destroy_recent_history_entries(new_history_entries)
      persist_entries!(new_entries)
    end
  end

  def persist_entries!(entries)
    return if entries.empty?

    entries.each { |entry| entry.item.save! }

    user.entries.insert_all!(
      entries.map { |entry| { item_id: entry.item.id, amount: entry.amount, timestamp: entry.timestamp } },
      record_timestamps: true
    )
  end

  def fetch_item(cache, mal_id:, kind:)
    cache["#{mal_id}:#{kind}"] ||= Item.find_or_initialize_by(mal_id:, kind:)
  end

  # Destroys the current recent entries from the oldest crawled entry date to not duplicate history
  # This list will come with the recent history, old entries should not be deleted
  # MAL just show a limit of 300 entries, so adding a limit to avoid old history deletion
  def destroy_recent_history_entries(entries)
    oldest_entry_date = entries.pluck("timestamp").min
    return if oldest_entry_date.blank?

    entries =
      user
        .entries
        .where(timestamp: Time.zone.parse(oldest_entry_date)..Float::INFINITY)
        .order(timestamp: :desc)
        .limit(300)

    # Sanity check, avoid deleting user history in case some date came with really old date
    if entries.any? && oldest_entry_date < 30.days.ago.at_beginning_of_day
      raise DeletingOldHistoryNotAllowed, "User: #{user} - Date: #{oldest_entry_date}"
    end

    entries.delete_all
  end
end
