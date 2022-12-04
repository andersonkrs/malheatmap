module Purgeable
  # Manages the lifecycle of a disposable object in the app
  #
  # After the record is created a job is scheduled in the future to try to purge the object and its dependencies from
  # the database automatically
  #
  # If the job fails by the exception RecordNotPurgeable, the job will be rescheduled with the exponential interval
  extend ActiveSupport::Concern

  class RecordNotPurgeable < StandardError
    attr_reader :created_at

    def initialize(msg = nil, created_at:)
      @created_at = created_at
      super(msg)
    end
  end

  included do
    class_attribute :_purgeable_after, default: nil

    after_commit :purge_later, on: :create, if: -> { self.class._purgeable_after.present? }
  end

  class_methods do
    def purge_after(period)
      self._purgeable_after = period
    end
  end

  def purge_later(after: self.class._purgeable_after)
    PurgeRecordJob.set(wait: after).perform_later(self)
  end

  def purge!
    raise Purgeable::RecordNotPurgeable.new(created_at:) unless can_be_purged?

    destroy!
  end

  private

  def can_be_purged?
    (Time.current - created_at) >= self.class._purgeable_after
  end
end
