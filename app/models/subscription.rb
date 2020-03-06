class Subscription < ApplicationRecord
  VALID_USERNAME_REGEX = %r{
    \A(http?s?://(?:www\.)?myanimelist\.net/profile/[A-Za-z0-9\-\_]+/?|[A-Za-z0-9\-\_]+)\Z
  }x.freeze

  enum status: {
    pending: "pending",
    success: "success",
    error: "error"
  }

  validates :username, presence: true
  validates :username, format: { with: VALID_USERNAME_REGEX }
  validates :status, presence: true

  after_validation :extract_username

  private

  def extract_username
    self.username = URI.parse(username).path.split("/").last
  rescue URI::InvalidURIError
    nil
  end
end
