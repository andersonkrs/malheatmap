class OpsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :ops }
end
