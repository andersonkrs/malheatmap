class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription = Subscription.find_by(id: params[:process_id], processed: false)
    return reject if subscription.blank?

    stream_for(subscription)
  end
end
