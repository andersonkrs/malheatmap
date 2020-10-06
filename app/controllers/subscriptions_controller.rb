class SubscriptionsController < ApplicationController
  def index
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      enqueue_process_job
    elsif user_already_subscribed?
      redirect_to_user_page
    end
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

  def enqueue_process_job
    response_delay_threshold = 2.seconds

    Subscription::ProcessJob.set(wait: response_delay_threshold).perform_later(@subscription)
  end
end
