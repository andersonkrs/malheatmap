class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription = Subscription.find_by(id: params[:process_id])
    return reject if subscription.blank? || !subscription.pending?

    stream_for(subscription)
    SubscriptionJob.perform_later(subscription)
  end
end
