class ApplicationJob < ActiveJob::Base
  def self.uniqueness_control(key:, expires_in:)
    before_enqueue ->(job) { validate_uniqueness(job, key: key.call(*job.arguments), expires_in:) }
  end

  def retry_job(...)
    self.class.suppress_uniqueness_control { super(...) }
  end

  def self.uniqueness_suppressor_registry
    ActiveSupport::IsolatedExecutionState[:active_job_uniqueness_control] ||= {}
  end

  def self.suppress_uniqueness_control
    previous_state = uniqueness_suppressor_registry[name]
    uniqueness_suppressor_registry[name] = true
    yield
  ensure
    uniqueness_suppressor_registry[name] = previous_state
  end

  private

  def validate_uniqueness(job, key:, expires_in:)
    return if self.class.uniqueness_suppressor_registry[self.class.name]

    limiter = Kredis.limiter("active-job-uniqueness:#{self.class.name}:#{key}", limit: 1, expires_in:)

    if limiter.exceeded?
      Rails.logger.warn("[Active Job] Unique job discarded #{job}")
      throw :abort
    else
      limiter.poke
    end
  end
end
