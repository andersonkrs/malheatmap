module UserData
  class Update < ApplicationPipelineService
    step Crawl
    step Save
    step GenerateActivitiesFromHistory, if: :new_data?

    private

    def new_data?
      context.data_updated
    end
  end
end
