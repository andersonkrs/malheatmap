class Subscription
  class Create < ApplicationService
    delegate :username, to: :context

    def call
      context.subscription = Subscription.create!(username: username, processed: false)

      Subscription::ProcessJob.set(wait: 1.second).perform_later(context.subscription)
    end
  end
end
