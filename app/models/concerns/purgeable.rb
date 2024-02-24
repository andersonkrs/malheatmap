module Purgeable
  # Manages the lifecycle of a disposable object in the app
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Configurable

    config_accessor :purge_after, instance_reader: false, instance_writer: false

    attribute :purge_after, :datetime, default: -> { config.purge_after }

    scope :due_for_purging, -> { where(purge_after: (..Time.current)) }

    after_create_commit -> { self.class.purge_due_later }
  end

  class_methods do
    def purge(after:)
      self.config.purge_after = after.from_now
    end

    def purge_due(batch_size: 500)
      loop do
        destroyed_batch = limit(batch_size).due_for_purging.destroy_all
        break if destroyed_batch.empty?
      end
    end

    def purge_due_later
      PurgeDueLaterJob.perform_later(self)
    end
  end

  class PurgeDueLaterJob < ApplicationJob
    queue_as :logging

    def perform(klass)
      klass.purge_due
    end
  end
end
