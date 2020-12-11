class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      render :create, status: :accepted
    elsif user_already_subscribed?
      redirect_to_user_page
    else
      render :create, status: :unprocessable_entity
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:username)
  end

  def user_already_subscribed?
    @subscription.errors.added?(:username, :taken)
  end

  def redirect_to_user_page
    redirect_to(user_path(@subscription.username), turbolinks: :advance)
  end
end
