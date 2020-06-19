class SubscriptionsController < ApplicationController
  def index
    @subscription = SubscriptionForm.new
  end

  def create
    @subscription = SubscriptionForm.new(subscription_params)
    return if @subscription.invalid?

    if @subscription.user_already_subscribed?
      redirect_to_user_page
    else
      @subscription.save!
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def redirect_to_user_page
    redirect_to user_path(@subscription.username), turbolinks: :advance
  end
end
