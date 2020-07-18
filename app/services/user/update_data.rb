class User
  class UpdateData < ApplicationPipeline
    step CrawlData
    step PersistCrawledData
    step GenerateActivitiesFromHistory, if: :new_data?
    step GenerateSignature

    private

    def new_data?
      context.data_updated
    end
  end
end
