class User
  class PersistCrawledData < ApplicationService
    delegate :user, :crawled_data, to: :context

    def call
      user.checksum = generate_data_checksum

      if user.checksum_changed?
        persist
        context.data_updated = true
      else
        context.data_updated = false
      end
    end

    private

    def generate_data_checksum
      json = Marshal.dump(crawled_data)
      Digest::MD5.hexdigest(json)
    end

    def persist
      ActiveRecord::Base.transaction do
        import_profile_data
        import_recent_history
      end
    end

    def import_profile_data
      user.assign_attributes(**crawled_data[:profile])
      user.save!
    end

    def import_recent_history
      user.history.visible_to_user_on_mal.delete_all

      crawled_data[:history].each do |entry|
        item = find_or_create_item(entry)

        Entry.create!(user: user, item: item, amount: entry[:amount], timestamp: entry[:timestamp])
      end
    end

    def find_or_create_item(entry)
      id, kind, name = entry.values_at(:item_id, :item_kind, :item_name)

      Item.find_or_create_by!(mal_id: id, kind: kind, name: name)
    end
  end
end
