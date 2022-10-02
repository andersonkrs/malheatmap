class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      @subscription.submitted
    elsif user_already_subscribed?
      return redirect_to_user_page
    end

    render :create
  end

  private

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def user_already_subscribed?
    @subscription.errors.added?(:username, :taken)
  end

  def redirect_to_user_page
    redirect_to(user_path(@subscription.username), turbo: :advance, format: :html)
  end
end
