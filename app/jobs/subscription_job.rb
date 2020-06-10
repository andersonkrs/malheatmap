class SubscriptionJob < ApplicationJob
  after_perform :set_as_processed

  private

  def perform(subscription)
    @subscription = subscription
    result = SubscribeUser.call(subscription: @subscription)

    response = if result.success?
                 { status: :success, user_url: user_path(result.user) }
               else
                 { status: :failure, template: render_error_alert(result.message) }
               end

    SubscriptionChannel.broadcast_to(@subscription, response)
  end

  def set_as_processed
    @subscription.update!(processed: true)
  end

  def render_error_alert(message)
    ApplicationController.render(partial: "subscriptions/alert", locals: { message: message })
  end
end
