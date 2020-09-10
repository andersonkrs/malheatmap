class SubscriptionsController < ApplicationController
  def index
    @subscription = SubscriptionForm.new
  end

  def create
    @subscription = SubscriptionForm.new(subscription_params)
    @subscription.save

    redirect_to_user_page if user_already_subscribed?
  end

  private

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def user_already_subscribed?
    @subscription.errors.of_kind?(:username, :taken)
  end

  def redirect_to_user_page
    redirect_to(user_path(@subscription.username), turbolinks: :advance)
  end
end
