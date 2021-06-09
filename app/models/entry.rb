class Entry < ApplicationRecord
  belongs_to :user, inverse_of: :entries
  belongs_to :item, autosave: true

  delegate :name, :kind, :mal_id, to: :item

  validates :timestamp, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
