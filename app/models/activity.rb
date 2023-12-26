class Activity < ApplicationRecord
  belongs_to :user, inverse_of: :activities
  belongs_to :item, autosave: true

  delegate :name, :kind, :mal_id, to: :item

  scope :ordered_as_timeline, -> { includes(:item).joins(:item).order(date: :desc, name: :asc) }
end
