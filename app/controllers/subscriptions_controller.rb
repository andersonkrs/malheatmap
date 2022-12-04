class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def show
    @subscription = Subscription.find(params[:id])
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      @subscription.submitted
      redirect_to(@subscription, turbo: :advance)
    elsif user_already_subscribed?
      redirect_to_user_page
    else
      render(:index, status: :unprocessable_entity)
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
    redirect_to(user_path(@subscription.username), turbo: :advance, format: :html)
  end
end
