module Patterns
  class Form
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def save
      validate ? persist : false
    end

    def save!
      validate!
      persist
    end
  end
end
