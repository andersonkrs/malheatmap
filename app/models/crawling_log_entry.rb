class CrawlingLogEntry < OpsRecord
  include Purgeable

  purge after: 3.days

  belongs_to :user

  has_many :visited_pages,
           class_name: "CrawlingLogEntryVisitedPage",
           dependent: :delete_all,
           inverse_of: :crawling_log_entry

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
        Rails.error.handle do
          instance.save!(validate: false)
        end
      end
    end
  end

  default_scope { extending(Recordable) }

  def success? = !failure?
end
