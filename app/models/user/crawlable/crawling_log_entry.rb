class User
  module Crawlable
    class CrawlingLogEntry < ApplicationRecord
      include Purgeable

      purge_after 30.days

      has_many_attached :visited_pages, service: :local

      belongs_to :user

      def raw_data=(value)
        compute_checksum
        super(value)
      end

      def apply_data_changes_to_user
        return if user.checksum == checksum

        transaction do
          update_history(raw_data["history"])
          update_profile(raw_data["profile"])
        end
      end

      private

      class DeletingOldHistoryNotAllowed < StandardError; end

      def compute_checksum
        self.checksum = OpenSSL::Digest::MD5.hexdigest(Marshal.dump(raw_data))
      end

      def update_profile(profile_data)
        user.update!(**profile_data, checksum: checksum)
      end

      def update_history(new_history_entries)
        return if new_history_entries.empty?

        destroy_recent_history_entries(new_history_entries)

        cached_items = {}
        new_history_entries.each do |entry_data|
          history_entry = user.entries.build(amount: entry_data["amount"], timestamp: entry_data["timestamp"])

          history_entry.item = fetch_item(cached_items, id: entry_data["item_id"], kind: entry_data["item_kind"])
          history_entry.item.name = entry_data["item_name"]
          history_entry.save!
        end
      end

      def fetch_item(cache, id:, kind:)
        cache["#{id}/#{kind}"] ||= Item.find_or_initialize_by(mal_id: id, kind: kind)
      end

      # Destroys the current recent entries from the oldest crawled entry date to not duplicate history
      # This list will come with the recent history, old entries should not be deleted
      # MAL just show a limit of 300 entries, so adding a limit to avoid old history deletion
      def destroy_recent_history_entries(entries)
        oldest_entry_date = entries.pluck("timestamp").min
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
end
