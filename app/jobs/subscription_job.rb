class SubscriptionJob < ApplicationJob
  attr_reader :subscription

  delegate :username, :reason, :status, to: :subscription

  after_perform :broadcast_result

  private

  def perform(subscription)
    @subscription = subscription

    response = UpdateService.call(username)
    subscription.update!(status: response[:status], reason: response[:message])
  end

  def broadcast_result
    data = if subscription.success?
             { user_url: user_path(username) }
           else
             { template: render_error_notification }
           end

    SubscriptionChannel.broadcast_to subscription, status: status, **data
  end

  def render_error_notification
    ApplicationController.render(
      partial: "shared/notifications",
      locals: {
        flash: { error: reason }
      }
    )
  end
end
