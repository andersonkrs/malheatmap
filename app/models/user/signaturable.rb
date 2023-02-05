class User
  module Signaturable
    extend ActiveSupport::Concern

    included { has_one_attached :signature }

    def signature_image
      @signature_image ||= SignatureImage.new(self)
    end
  end
end
