module Purgeable
  # Manages the lifecycle of a disposable object in the app
  extend ActiveSupport::Concern

  included do
    class_attribute :_purgeable_after, default: nil
    class_attribute :_purgeable_method, default: nil

    attribute :purge_after, :datetime, default: -> { _purgeable_after }
    attribute :purge_method, :string, default: -> { _purgeable_method }

    enum purge_method: { deletion: "deletion", destruction: "destruction" }, _prefix: "purge_with"

    scope :due_for_purging, -> { where(purge_after: (..Time.current)) }
  end

  class_methods do
    def purge(after:, method:)
      self._purgeable_after = after.from_now
      self._purgeable_method = method
    end

    def purge_due(batch_size: 500)
      destroyed_records = limit(batch_size).due_for_purging.purge_with_destruction.destroy_all

      limit(batch_size - destroyed_records.size).due_for_purging.purge_with_deletion.delete_all
    end
  end
end
