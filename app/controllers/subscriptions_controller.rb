class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    return render_error_notification if subscription.invalid?

    if already_subscribed?
      redirect_to user_path(subscription.username)
    else
      save_and_enqueue_process
      render_loader
    end
  end

  private

  attr_reader :subscription

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def save_and_enqueue_process
    subscription.status = :pending
    subscription.save

    SubscriptionJob.perform_later(subscription)
  end

  def already_subscribed?
    User.exists?(username: subscription.username)
  end

  def render_error_notification
    flash.now[:error] = subscription.errors.full_messages.first
    render "shared/_notifications", status: :bad_request, layout: false
  end

  def render_loader
    response.set_header("ProcessID", subscription.id)
    render "_loader", status: :accepted, layout: false
  end
end
