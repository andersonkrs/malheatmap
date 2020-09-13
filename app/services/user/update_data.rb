class User
  class UpdateData < ApplicationPipeline
    step CrawlData
    step PersistCrawledData, if: :checksum_changed?
    step GenerateActivitiesFromHistory, if: :checksum_changed?
    step GenerateSignature

    private

    def checksum_changed?
      @checksum_changed ||= context.checksum != context.user.checksum
    end
  end
end
