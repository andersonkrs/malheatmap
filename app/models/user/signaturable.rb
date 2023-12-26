class User
  module Signaturable
    extend ActiveSupport::Concern

    included do
      has_one_attached :signature

      after_create_commit :enqueue_signature_generation
      after_update_commit :enqueue_signature_generation, if: -> { signature_image.obsolete? }
    end

    def signature_image
      SignatureImage.new(self)
    end

    private

    def enqueue_signature_generation
      signature_image.generate_later
    end
  end
end
