class User
  class PersistCrawledData < ApplicationService
    delegate :user, :crawled_data, :checksum, to: :context

    before_call do
      @processed_items = {}
    end

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
      user.history.visible_to_user_on_mal.delete_all

      crawled_data[:history].each do |entry|
        insert_entry(entry)
      end
    end

    def insert_entry(entry)
      item_data = map_item_from_entry(entry)

      item_id = find_processed_item_id(item_data)
      item_id ||= upsert_item(item_data)

      user.entries.create!(item_id: item_id, amount: entry[:amount], timestamp: entry[:timestamp])
    end

    def map_item_from_entry(entry)
      {
        mal_id: entry[:item_id],
        kind: entry[:item_kind],
        name: entry[:item_name]
      }
    end

    def find_processed_item_id(item_data)
      @processed_items.key(item_data)
    end

    def upsert_item(item_data)
      result = Item.upsert(item_data, unique_by: %i[mal_id kind])

      result.first["id"].tap do |item_id|
        @processed_items[item_id] = item_data
      end
    end
  end
end
