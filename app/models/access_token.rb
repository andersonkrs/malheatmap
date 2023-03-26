class AccessToken < ApplicationRecord
  encrypts :token, deterministic: true
  encrypts :refresh_token, deterministic: true

  belongs_to :user

  before_create { self.refresh_token_expires_at ||= 30.days.from_now }
end
