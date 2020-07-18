module NoRetryJob
  extend ActiveSupport::Concern

  included do
    sidekiq_options retry: false
  end
end
