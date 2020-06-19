class ProcessSubscriptionJob < ApplicationJob
  private

  def perform(subscription)
    ProcessSubscription.call(subscription: subscription)
  end
end
