class User < ApplicationRecord
  include Authenticatable
  include MALSyncable
  include Mergeable
  include Calendars
  include CalendarImageable
  include Deactivatable
  include Geolocatable

  after_update_commit -> { broadcast_replace_later(partial: "users/user", locals: { user: self }) }

  has_many :entries, -> { preload(:item) }, inverse_of: :user, dependent: :delete_all
  has_many :activities, -> { preload(:item) }, inverse_of: :user, dependent: :delete_all do
    def generate_from_history
      ActivitiesGenerator.new(proxy_association.owner).run
    end
  end

  def with_time_zone(&)
    Time.use_zone(time_zone, &)
  end

  def to_param
    username
  end

  def to_s
    username
  end
end
