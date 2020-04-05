class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :item

  delegate :name, :kind, :mal_id, to: :item

  validates :timestamp, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :last_three_weeks, lambda {
    where("timestamp >= ?", 3.weeks.ago.at_beginning_of_day.in_time_zone)
  }
end
