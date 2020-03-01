class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription_process = Subscription.find_by(id: params[:process_id])
    return reject if subscription_process.blank?

    stream_for subscription_process
  end
end
