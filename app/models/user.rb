class User < ApplicationRecord
  include Crawlable
  include GeneratableSignature
  include GeneratableActivities
  include Mergeable

  validates :time_zone, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true

  has_many :entries, dependent: :delete_all, inverse_of: :user
  has_many :activities, dependent: :delete_all, inverse_of: :user do
    def for_date_range(range)
      where(date: range)
    end

    def ordered_as_timeline
      includes(:item)
        .joins(:item)
        .order(date: :desc, name: :asc)
    end

    def first_date
      Rails.cache.fetch("#{proxy_association.owner.cache_key_with_version}/first-activity-date") do
        order(date: :asc).limit(1).pick(:date)
      end
    end
  end

  def active_years
    initial_date = [created_at.to_date, activities.first_date].compact.min

    (initial_date.year..Time.zone.today.year)
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
