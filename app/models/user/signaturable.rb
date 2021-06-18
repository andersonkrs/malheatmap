class User
  module Signaturable
    extend ActiveSupport::Concern

    included do
      has_one_attached :signature
    end

    def signature_image
      @signature_image ||= SignatureImage.new(self)
    end
  end
end
