class ApplicationJob < ActiveJob::Base
  include UniqueJobs

  retry_on(ActiveRecord::StatementInvalid, attempts: 10, wait: :polynomially_longer)
end
