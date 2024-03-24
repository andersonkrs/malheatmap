module UniqueJobs
  extend ActiveSupport::Concern

  class_methods do
    def uniqueness_control(key:, expires_in:)
      before_enqueue ->(job) do
        validate_uniqueness(job, key: key.call(*job.arguments), expires_in:)
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

    normalized_key = [key].flatten.compact.join(":")
    counter_key = "active-job-uniqueness:#{self.class.name}:#{normalized_key}"

    if Rails.cache.read(counter_key)
      Rails.logger.warn("[Active Job] Unique job discarded #{job}")
      throw :abort
    end

    Rails.cache.write(counter_key, true, expires_in: expires_in)
  end
end
