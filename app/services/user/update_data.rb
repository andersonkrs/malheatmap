class User
  class UpdateData < ApplicationPipeline
    delegate :user, to: :context

    step CrawlData
    step DetermineGeolocation, if: :location_changed?
    step PersistCrawledData, if: :checksum_changed?
    step GenerateActivitiesFromHistory, if: :checksum_changed?
    step GenerateSignature, if: :signature_need_to_be_updated?

    private

    def checksum_changed?
      @checksum_changed ||= context.checksum != user.checksum
    end

    def location_changed?
      return true if checksum_changed?

      user.location != context.crawled_data.dig(:profile, :location)
    end

    def signature_need_to_be_updated?
      return true if checksum_changed?
      return true unless user.signature.attached?

      user.signature.blob.created_at.to_date != Time.find_zone(user.time_zone).today
    end
  end
end
