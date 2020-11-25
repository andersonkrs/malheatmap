class Subscription
  class ProcessJob < ApplicationJob
    include NoRetryJob

    def self.enqueue(subscription)
      set(wait: RESPONSE_DELAY_THRESHOLD).perform_later(subscription)
    end

    private

    RESPONSE_DELAY_THRESHOLD = 2.seconds

    def perform(subscription)
      subscription.process!
    end
  end
end
