class User
  module Mergeable
    extend ActiveSupport::Concern

    def merge!(old_user)
      ApplicationRecord.transaction do
        old_user.entries.update_all(user_id: id)
        old_user.destroy

        update!(checksum: nil)
      end
    end
  end
end
