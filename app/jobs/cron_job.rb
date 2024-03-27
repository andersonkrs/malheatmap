class CronJob < ApplicationJob
  queue_as :default

  def perform(ruby_code)
    eval(ruby_code)
  end
end
