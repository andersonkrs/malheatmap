class Entry < ApplicationRecord
  belongs_to :user, inverse_of: :entries
  belongs_to :item, autosave: true

  delegate :name, :kind, :mal_id, to: :item
end
