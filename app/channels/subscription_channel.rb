class SubscriptionChannel < ApplicationCable::Channel
  def subscribed
    subscription = Subscription.find_by(id: params[:process_id], processed: false)

    stream_or_reject_for(subscription)
  end
end
