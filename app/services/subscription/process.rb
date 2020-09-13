class Subscription
  class Process < ApplicationService
    delegate :subscription, to: :context

    before_call do
      context.user = User.create!(username: subscription.username)
    end

    def call
      result = User::UpdateData.call(user: context.user)

      if result.success?
        context.response = { status: :success, redirect: user_path(context.user) }
      else
        rollback
        context.response = { status: :failure, notification: render_error_notification(result.message) }
      end
    end

    rescue_from StandardError do |exception|
      NotifyError.call!(error: exception)
      context.response = { status: :failure, redirect: internal_error_path }
    end

    ensure_call do
      SubscriptionChannel.broadcast_to(subscription, context.response)
      subscription.update!(processed: true)
    end

    def rollback
      context.user&.destroy
    end

    private

    def render_error_notification(message)
      ApplicationController.render NotificationComponent.new(message: message)
    end
  end
end
