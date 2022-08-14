class Subscription < ApplicationRecord
  include Processable
  include Purgeable

  purge_after 3.days

  USERNAME_REGEX = %r{\A(http?s?://(?:www\.)?myanimelist\.net/(profile|history)/[A-Za-z0-9\-_]+/?|
                      [A-Za-z0-9\-_]+)\Z}x

  attr_accessor :redirect_path

  validates :username, presence: true, format: { with: USERNAME_REGEX }
  validate :user_already_subscribed, on: :create

  private

  def user_already_subscribed
    clean_username
    errors.add(:username, :taken) if User.exists?(username: username)
  end

  def clean_username
    self.username = URI.parse(username).path.split("/").last
  rescue URI::InvalidURIError
    self.username = nil
  end
end
