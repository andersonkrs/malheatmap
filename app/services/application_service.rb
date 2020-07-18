class ApplicationService
  include Patterns::Service
  include Rails.application.routes.url_helpers
end
