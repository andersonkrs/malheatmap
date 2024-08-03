class ApplicationJob < ActiveJob::Base
  include UniqueJobs

  retry_on(ActiveRecord::StatementInvalid, attempts: 3, wait: :polynomially_longer)
end
