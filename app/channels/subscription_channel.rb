class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription = Subscription.pending.find_by(id: params[:process_id])

    stream_or_reject_for(subscription)
  end
end
