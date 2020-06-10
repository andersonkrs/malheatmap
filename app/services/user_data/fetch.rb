module UserData
  class Fetch < ApplicationPipelineService
    step Crawl
    step Import
    step GenerateActivitiesFromHistory, if: :new_data?

    private

    def new_data?
      context.data_updated
    end
  end
end
