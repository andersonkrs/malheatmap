module Patterns
  module Form
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      def model_name
        ActiveModel::Name.new(self, nil, self.class.to_s.demodulize.remove("Form"))
      end

      def save
        if validate
          persist
          true
        else
          false
        end
      end

      def save!
        validate!
        persist
      end
    end
  end
end
