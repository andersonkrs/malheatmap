class SubscribeUser < ApplicationService
  delegate :subscription, to: :context

  def call
    context.user = User.create!(username: subscription.username)

    UserData::Fetch.call!(user: context.user)
  end

  def rollback
    context.user.destroy
  end
end
