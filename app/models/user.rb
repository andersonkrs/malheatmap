class User < ApplicationRecord
  include Crawlable
  include GeneratableSignature
  include GeneratableActivities

  validates :time_zone, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true

  has_many :entries, dependent: :delete_all, inverse_of: :user do
    def visible_to_user_on_mal
      history_limit_date = 20.days.ago.at_beginning_of_day

      where("timestamp >= ?", history_limit_date)
    end
  end

  has_many :activities, dependent: :delete_all, inverse_of: :user do
    def for_date_range(range)
      where(date: range)
    end

    def ordered_as_timeline
      includes(:item)
        .joins(:item)
        .order(date: :desc, name: :asc)
    end

    def unique_years
      Rails.cache.fetch("#{proxy_association.owner.cache_key_with_version}/unique-years") do
        distinct
          .order(year: :desc)
          .pluck(Arel.sql("cast(date_part('year', date) as int) as year"))
      end
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
