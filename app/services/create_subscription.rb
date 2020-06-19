class CreateSubscription < ApplicationService
  delegate :username, to: :context

  def call
    context.subscription = Subscription.create!(username: username, processed: false)

    ProcessSubscriptionJob.set(wait: 1.second).perform_later(context.subscription)
  end
end
