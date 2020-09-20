class User
  class UpdateDataJob < ApplicationJob
    queue_as :low

    before_perform do |job|
      Rails.logger.info("Updating data for user: #{job.arguments.first}")
    end

    after_perform do |job|
      Rails.logger.info(job.job_result)
    end

    attr_reader :job_result

    def perform(user)
      result = User::UpdateData.call(user: user)

      @job_result = { success: result.success?, message: result.message }
    end
  end
end
