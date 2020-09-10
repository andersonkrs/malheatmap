class SubscriptionForm < ApplicationForm
  attr_accessor :id, :username

  USERNAME_REGEX = %r{\A(http?s?://(?:www\.)?myanimelist\.net/(profile|history)/[A-Za-z0-9\-_]+/?|
                      [A-Za-z0-9\-_]+)\Z}x.freeze

  validates :username, presence: true, format: { with: USERNAME_REGEX }
  validate :user_already_subscribed

  private

  def persist
    result = Subscription::Create.call!(username: username)
    self.id = result.subscription.id
  end

  def user_already_subscribed
    clean_username
    return if username.blank?

    errors.add(:username, :taken) if User.exists?(username: username)
  end

  def clean_username
    self.username = URI.parse(username).path.split("/").last
  rescue URI::InvalidURIError
    self.username = nil
  end
end
