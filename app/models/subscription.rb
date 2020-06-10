class Subscription < ApplicationRecord
  validates :username, presence: true
end
