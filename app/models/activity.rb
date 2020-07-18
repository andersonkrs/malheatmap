class Activity < ApplicationRecord
  belongs_to :user, inverse_of: :activities
  belongs_to :item

  delegate :name, :kind, :mal_id, to: :item

  validates :amount, presence: true, numericality: { only_integer: true }
  validates :date, presence: true
end
