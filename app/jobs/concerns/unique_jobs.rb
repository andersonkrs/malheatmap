module UniqueJobs
  extend ActiveSupport::Concern

  class_methods do
    def uniqueness_control(key:, expires_in:)
      before_enqueue ->(job) do
        validate_uniqueness(job, key: key.call(*job.arguments), expires_in:)
      end

      after_perform do |job|
        release_uniqueness_lock(job, key: key.call(*job.arguments))
      end

      after_discard do |job, exception|
        release_uniqueness_lock(job, key: key.call(*job.arguments))
      end
    end

    def uniqueness_suppressor_registry
      ActiveSupport::IsolatedExecutionState[:active_job_uniqueness_control] ||= {}
    end

    def suppress_uniqueness_control
      previous_state = uniqueness_suppressor_registry[name]
      uniqueness_suppressor_registry[name] = true
      yield
    ensure
      uniqueness_suppressor_registry[name] = previous_state
    end
  end

  def retry_job(...)
    self.class.suppress_uniqueness_control { super(...) }
  end

  private

  def validate_uniqueness(job, key:, expires_in:)
    return if self.class.uniqueness_suppressor_registry[self.class.name]

    lock_key = uniqueness_lock(key)

    if Rails.cache.read(lock_key)
      Rails.logger.warn("[Active Job] Job Discarded #{job}. Unique Lock Held by #{lock_key}")
      throw :abort
    end

    Rails.cache.write(lock_key, true, expires_in: expires_in)
  end

  def release_uniqueness_lock(job, key:)
    lock_key = uniqueness_lock(key)
    Rails.cache.delete(lock_key)
  end

  def uniqueness_lock(key)
    normalized_key = [key].flatten.compact.join(":")
    "active-job-uniqueness:#{self.class.name}:#{normalized_key}"
  end
end
