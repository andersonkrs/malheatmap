class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription = Subscription.find_by(id: params[:process_id])
    return reject if subscription.blank? || subscription.processed?

    stream_for(subscription)
  end
end
