class User
  class CrawledDataProcessor
    attr_reader :user, :data, :new_checksum

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

      user.entries.visible_to_user_on_mal.delete_all

      data[:history].each do |entry_data|
        create_entry(entry_data)
      end
    end

    def create_entry(data)
      entry = user.entries.build(amount: data[:amount], timestamp: parse_natural_timestamp(data[:timestamp]))

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
