class Item < ApplicationRecord
  enum kind: { anime: "anime", manga: "manga" }
end
