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
      user.history.visible_to_user_on_mal.delete_all

      crawled_data[:history].each do |entry|
        item_id = upsert_item(entry)

        user.entries.create!(item_id: item_id, amount: entry[:amount], timestamp: entry[:timestamp])
      end
    end

    def upsert_item(entry)
      item_data = {
        mal_id: entry[:item_id],
        kind: entry[:item_kind],
        name: entry[:item_name],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }

      result = Item.upsert(item_data, unique_by: %i[mal_id kind]) # rubocop:disable Rails/SkipsModelValidations
      result.first["id"]
    end
  end
end
