class User
  module GeneratableSignature
    extend ActiveSupport::Concern

    included do
      has_one_attached :signature

      set_callback :crawl, :after, :generate_signature, if: :signature_need_to_be_generated?
    end

    def generate_signature
      SignatureGenerator.new(self).run
    end

    private

    def signature_need_to_be_generated?
      saved_change_to_checksum? || !signature.attached? || obsolete_signature?
    end

    def obsolete_signature?
      with_time_zone do
        signature.blob.created_at.to_date != Time.zone.today
      end
    end
  end
end
