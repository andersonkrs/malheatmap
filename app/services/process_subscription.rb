class ProcessSubscription < ApplicationService
  delegate :subscription, :user, to: :context

  before_call do
    context.user = User.create!(username: subscription.username)
  end

  def call
    result = UpdateUserData.call(user: user)

    if result.success?
      context.response = { status: :success, user_url: user_path(user) }
    else
      context.response = { status: :failure, template: render_error_alert(result.message) }
      rollback
    end
  end

  after_call do
    SubscriptionChannel.broadcast_to(subscription, context.response)
    subscription.update!(processed: true)
  end

  def rollback
    context.user.destroy
  end

  private

  def render_error_alert(message)
    ApplicationController.render NotificationComponent.new(message: message)
  end
end
