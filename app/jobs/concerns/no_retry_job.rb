module NoRetryJob
  extend ActiveSupport::Concern

  included { sidekiq_options retry: false }
end
