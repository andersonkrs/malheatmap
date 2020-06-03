class SubscriptionJob < ApplicationJob
  attr_reader :subscription
  delegate :username, to: :subscription

  after_perform :set_as_processed

  private

  def perform(subscription)
    @subscription = subscription

    result = SyncronizationService.syncronize_user_data(username)
    response = if result[:status] == :success
                 { status: :success, user_url: user_path(username) }
               else
                 { status: :failure, template: render_error_alert(result[:message]) }
               end

    SubscriptionChannel.broadcast_to subscription, response
  end

  def render_error_alert(message)
    ApplicationController.render(partial: "subscriptions/alert", locals: { message: message })
  end

  def set_as_processed
    subscription.update!(processed: true)
  end
end
