class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    return if @subscription.invalid?

    if already_subscribed?
      redirect_to_user_page
    else
      @subscription.save!
      enqueue_process
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def already_subscribed?
    User.exists?(username: @subscription.username)
  end

  def enqueue_process
    SubscriptionJob.set(wait: 1.second).perform_later(@subscription)
  end

  def redirect_to_user_page
    redirect_to user_path(@subscription.username), turbolinks: :advance
  end
end
