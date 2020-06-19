class SubscriptionForm < ApplicationForm
  attr_accessor :id, :username

  VALID_USERNAME_REGEX = %r{
    \A(http?s?://(?:www\.)?myanimelist\.net/profile/[A-Za-z0-9\-\_]+/?|[A-Za-z0-9\-\_]+)\Z
  }x.freeze

  validates :username, presence: true, format: { with: VALID_USERNAME_REGEX }
  after_validation :clean_username

  def user_already_subscribed?
    User.exists?(username: username)
  end

  def model_name
    ActiveModel::Name.new(self, nil, "Subscription")
  end

  private

  def persist
    result = CreateSubscription.call(username: username)
    self.id = result.subscription.id
  end

  def clean_username
    self.username = URI.parse(username).path.split("/").last
  rescue URI::InvalidURIError
    self.username = nil
  end
end
