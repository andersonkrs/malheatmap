class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
end
