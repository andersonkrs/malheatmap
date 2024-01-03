class CrawlingLogEntry < OpsRecord
  include Purgeable

  purge after: 10.days, method: :deletion

  module AssociationRecordable
    def record
      instance = proxy_association.klass.new(user: proxy_association.owner)
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

  default_scope { extending(AssociationRecordable) }

  def success? = !failure?

  def save_later
    SaveAsyncJob.set(wait: 5.seconds).perform_later(attributes.to_json)
  end

  class SaveAsyncJob < ApplicationJob
    discard_on ActiveSupport::JSON.parse_error

    retry_on ActiveRecord::StatementInvalid, wait: :polynomially_longer, attempts: 5

    def perform(json_attrs)
      arguments = ActiveSupport::JSON.decode(json_attrs)

      record = CrawlingLogEntry.new(**arguments)
      record.save!(validate: false)
    end
  end
end
