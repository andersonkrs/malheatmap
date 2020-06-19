class UpdateUserData < ApplicationPipelineService
  step CrawlUserData
  step PersistCrawledUserData
  step GenerateUserActivitiesFromHistory, if: :new_data?

  private

  def new_data?
    context.data_updated
  end
end
