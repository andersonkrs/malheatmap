class Entry < ApplicationRecord
  belongs_to :user

  enum item_kind: {
    anime: "anime",
    manga: "manga"
  }

  validates :timestamp, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :item_id, numericality: { greater_than: 0 }
  validates :item_name, presence: true
  validates :item_kind, presence: true

  default_scope { order(timestamp: :desc) }
  scope :last_three_weeks, lambda {
    where("timestamp >= ?", 3.weeks.ago.at_beginning_of_day.in_time_zone)
  }
end
