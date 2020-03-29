class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :item

  delegate :name, :kind, :mal_id, to: :item

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :date, presence: true
end
