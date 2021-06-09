class User
  class CrawledData
    class DeletingOldHistoryNotAllowed < StandardError; end

    def initialize(user)
      super()
      @user = user
      @new_checksum = nil
      @cached_items = {}
    end

    def import(new_data)
      generate_checksum(new_data)
      return unless changed?

      user.transaction do
        update_history(new_data[:history])
        update_profile(new_data[:profile])
      end
    end

    def changed?
      @changed ||= user.checksum != new_checksum
    end

    private

    attr_reader :user, :cached_items, :new_checksum

    def generate_checksum(data)
      json = Marshal.dump(data)
      @new_checksum = OpenSSL::Digest::MD5.hexdigest(json)
      @changed = nil
    end

    def update_profile(profile_data)
      user.update!(**profile_data, checksum: new_checksum)
    end

    def update_history(new_entries)
      return if new_entries.empty?

      destroy_recent_entries(new_entries)

      new_entries.each do |entry_data|
        entry = user.entries.build(amount: entry_data[:amount], timestamp: entry_data[:timestamp])

        entry.item = find_item(entry_data[:item_id], entry_data[:item_kind])
        entry.item.name = entry_data[:item_name]
        entry.save!
      end
    end

    def find_item(item_id, item_kind)
      cached_items["#{item_id}/#{item_kind}"] ||= Item.find_or_initialize_by(mal_id: item_id, kind: item_kind)
    end

    # Destroys the current recent entries from the oldest crawled entry date to not duplicate history
    # This list will come with the recent history, old entries should not be deleted
    # MAL just show a limit of 300 entries, so adding a limit to avoid old history deletion
    def destroy_recent_entries(entries)
      oldest_entry_date = entries.pluck(:timestamp).min
      return if oldest_entry_date.blank?

      entries = user
                  .entries
                  .where("timestamp >= ?", oldest_entry_date)
                  .order(timestamp: :desc)
                  .limit(300)

      # Sanity check, avoid deleting user history in case some date came with really old date
      if entries.any? && oldest_entry_date < 30.days.ago.at_beginning_of_day
        raise DeletingOldHistoryNotAllowed, "User: #{user} - Date: #{oldest_entry_date}"
      end

      entries.delete_all
    end
  end
end
