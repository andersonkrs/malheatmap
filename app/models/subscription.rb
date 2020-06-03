class Subscription < ApplicationRecord
  VALID_USERNAME_REGEX = %r{
    \A(http?s?://(?:www\.)?myanimelist\.net/profile/[A-Za-z0-9\-\_]+/?|[A-Za-z0-9\-\_]+)\Z
  }x.freeze

  validates :username, presence: true, format: { with: VALID_USERNAME_REGEX }

  after_validation :clean_username

  private

  def clean_username
    self.username = URI.parse(username).path.split("/").last
  rescue URI::InvalidURIError
    self.username = nil
  end
end
