class User
  class PersistCrawledData < ApplicationService
    delegate :user, :crawled_data, :checksum, to: :context

    def call
      ActiveRecord::Base.transaction do
        update_profile_data
        update_recent_history
      end
    end

    private

    def update_profile_data
      user.update!(**crawled_data[:profile], checksum: checksum)
    end

    def update_recent_history
      return if crawled_data[:history].empty?

      user.history.visible_to_user_on_mal.delete_all
      save_items
      insert_entries
    end

    def save_items
      items = crawled_data[:history].map do |entry|
        {
          mal_id: entry[:item_id],
          kind: entry[:item_kind],
          name: entry[:item_name]
        }
      end.uniq

      @saved_items = Item.upsert_all(items, unique_by: %i[mal_id kind], returning: %i[id name mal_id kind])
      @saved_items.each(&:symbolize_keys!)
    end

    def insert_entries
      entries = crawled_data[:history].map do |entry|
        {
          user_id: user.id,
          item_id: item_id_for_entry(entry),
          amount: entry[:amount],
          timestamp: convert_natural_timestamp(entry[:timestamp])
        }
      end

      Entry.insert_all(entries)
    end

    def item_id_for_entry(entry)
      item = @saved_items.find do |saved_item|
        saved_item.values_at(:mal_id, :kind) == entry.values_at(:item_id, :item_kind)
      end
      item[:id]
    end

    def convert_natural_timestamp(natural_timestamp)
      Time.use_zone(user.time_zone) do
        Chronic
          .parse(natural_timestamp, context: :past, now: Time.zone.now)
          .change(sec: 0, usec: 0, offset: Time.zone.formatted_offset)
          .utc
      end
    end
  end
end
