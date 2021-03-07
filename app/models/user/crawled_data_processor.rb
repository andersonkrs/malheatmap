class User
  class CrawledDataProcessor
    class DeletingOldHistoryNotAllowed < StandardError; end

    def initialize(user, data)
      @user = user
      @data = data
      @new_checksum = nil
    end

    def run
      generate_checksum

      return unless checksum_will_change?

      save
    end

    private

    attr_reader :user, :data, :new_checksum

    def generate_checksum
      json = Marshal.dump(data)
      @new_checksum = OpenSSL::Digest::MD5.hexdigest(json)
    end

    def checksum_will_change?
      user.checksum != new_checksum
    end

    def save
      ActiveRecord::Base.transaction do
        update_profile
        update_current_history
      end
    end

    def update_profile
      user.update!(checksum: new_checksum, **data[:profile])
    end

    def update_current_history
      return if data[:history].empty?

      map_entries_timestamp
      delete_recent_entries

      data[:history].each do |entry_data|
        create_entry(entry_data)
      end
    end

    def map_entries_timestamp
      data[:history].map! do |entry|
        entry[:timestamp] = parse_natural_timestamp(entry[:timestamp])
        entry
      end
    end

    # Deletes the current recent entries from the oldest crawled entry date to not duplicate history
    # This list will come with the recent history, old entries should not be deleted
    # Mal just show a limit of 300 entries, so adding a limit to avoid old history deletion
    def delete_recent_entries
      return if oldest_crawled_entry_date.blank?

      recent_entries = user
                         .entries
                         .order(timestamp: :desc)
                         .where("timestamp >= ?", oldest_crawled_entry_date)
                         .limit(300)

      return if recent_entries.none?

      # Sanity check, avoid deleting user history in case some date came with realy old date
      if oldest_crawled_entry_date < 30.days.ago.at_beginning_of_day
        raise DeletingOldHistoryNotAllowed, "User: #{@user} - Date: #{oldest_crawled_entry_date}"
      end

      recent_entries.delete_all
    end

    def oldest_crawled_entry_date
      @oldest_crawled_entry_date ||= begin
        oldest_entry = data[:history].min_by { |entry| entry[:timestamp] }
        oldest_entry[:timestamp]
      end
    end

    def create_entry(data)
      entry = user.entries.build(amount: data[:amount], timestamp: data[:timestamp])

      entry.item = Item.find_or_initialize_by(mal_id: data[:item_id], kind: data[:item_kind])
      entry.item.name = data[:item_name]
      entry.item.save!
      entry.save!
    end

    def parse_natural_timestamp(text)
      user.with_time_zone do
        date = Chronic.parse(text, context: :past, now: Time.zone.now)

        date.change(sec: 0, usec: 0, offset: Time.zone.formatted_offset).utc
      end
    end
  end
end
