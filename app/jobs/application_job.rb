class ApplicationJob < ActiveJob::Base
  include UniqueJobs
end
