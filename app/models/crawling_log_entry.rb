class CrawlingLogEntry < OpsRecord
  include Purgeable

  purge after: 5.days, method: :deletion

  module Recordable
    def record
      instance = proxy_association.klass.new(user_id: proxy_association.owner.id)
      begin
        yield(instance)
      rescue StandardError => error
        instance.failure = true
        instance.failure_message = error.message
        raise
      ensure
        instance.save_later
      end
    end
  end

  belongs_to :user

  default_scope { extending(Recordable) }

  def success? = !failure?

  def save_later
    SaveAsyncJob.set(wait: 5.seconds).perform_later(attributes.except("id"))
  end

  class SaveAsyncJob < ApplicationJob
    queue_as :logging

    def perform(attributes)
      CrawlingLogEntry.create!(**attributes)
    end
  end
end
