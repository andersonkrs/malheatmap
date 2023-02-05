class Item < ApplicationRecord
  enum kind: { anime: "anime", manga: "manga" }

  validates :mal_id, numericality: { greater_than: 0 }
  validates :name, presence: true
  validates :kind, presence: true
end
