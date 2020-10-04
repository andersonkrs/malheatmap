class User
  class UpdateData < ApplicationPipeline
    step CrawlData
    step DetermineGeolocation, if: :location_changed?
    step PersistCrawledData, if: :checksum_changed?
    step GenerateActivitiesFromHistory, if: :checksum_changed?
    step GenerateSignature

    private

    def checksum_changed?
      @checksum_changed ||= context.checksum != context.user.checksum
    end

    def location_changed?
      return true if checksum_changed?

      context.user.location != context.crawled_data.dig(:profile, :location)
    end
  end
end
