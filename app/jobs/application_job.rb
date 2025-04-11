class ApplicationJob < ActiveJob::Base
  include UniqueJobs

  retry_on(ActiveRecord::StatementInvalid, attempts: 10, wait: :polynomially_longer)
  retry_on(
    SolidQueue::Processes::ProcessExitError,
    SolidQueue::Processes::ProcessPrunedError,
    attempts: 5,
    wait: 5.minutes,
  )
end
