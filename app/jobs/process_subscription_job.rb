class ProcessSubscriptionJob < ApplicationJob
  include NoRetryJob

  private

  def perform(subscription)
    ProcessSubscription.call(subscription: subscription)
  end
end
