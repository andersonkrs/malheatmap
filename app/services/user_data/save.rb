module UserData
  class Save < ApplicationService
    delegate :user, :crawled_data, to: :context

    before do
      user.checksum = generate_data_checksum
    end

    def call
      unless user.checksum_changed?
        context.data_updated = false
        return
      end

      persist
      context.data_updated = true
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
      delete_last_entries

      crawled_data[:history].each do |entry|
        item = find_or_create_item(entry)

        Entry.create!(
          user: user,
          item: item,
          amount: entry[:amount],
          timestamp: entry[:timestamp]
        )
      end
    end

    def delete_last_entries
      entries = UserQueries::EntriesFromLastThreeWeeks.execute(user: user)
      entries.delete_all
    end

    def find_or_create_item(entry)
      id, kind, name = entry.values_at(:item_id, :item_kind, :item_name)

      Item.find_or_create_by!(mal_id: id, kind: kind, name: name)
    end
  end
end
