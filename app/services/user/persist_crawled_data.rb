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
        item = find_or_create_item(entry)

        user.entries.create!(item: item, amount: entry[:amount], timestamp: entry[:timestamp])
      end
    end

    def find_or_create_item(entry)
      id, kind, name = entry.values_at(:item_id, :item_kind, :item_name)

      Item.find_or_create_by!(mal_id: id, kind: kind, name: name)
    end
  end
end
