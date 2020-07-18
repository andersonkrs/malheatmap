class Subscription
  class ProcessJob < ApplicationJob
    include NoRetryJob

    private

    def perform(subscription)
      Subscription::Process.call(subscription: subscription)
    end
  end
end
