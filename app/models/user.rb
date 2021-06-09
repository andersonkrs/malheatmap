class User < ApplicationRecord
  include Crawlable
  include Mergeable

  has_one_attached :signature

  has_many :entries, -> { includes(:item) }, inverse_of: :user, dependent: :delete_all
  has_many :activities, -> { includes(:item) }, inverse_of: :user, dependent: :delete_all do
    def generate_from_history
      ActivitiesGenerator.new(proxy_association.owner).run
    end
  end

  validates :time_zone, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true

  def calendar_dates
    @calendar_dates ||= CalendarDates.new
  end

  def signature_image
    @signature_image ||= SignatureImage.new(self)
  end

  def active_years
    @active_years ||= begin
      first_activity_date = activities.order(date: :asc).limit(1).pick(:date)
      initial_date = [created_at.to_date, first_activity_date].compact.min

      (initial_date.year..Time.zone.today.year)
    end
  end

  def with_time_zone(&block)
    Time.use_zone(time_zone) { block.call }
  end

  def to_param
    username
  end

  def to_s
    username
  end
end
