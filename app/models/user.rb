class User < ApplicationRecord
  has_one_attached :signature

  validates :time_zone, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true

  has_many :entries, dependent: :delete_all, inverse_of: :user do
    def visible_to_user_on_mal
      history_limit_date = (MAL::USER_HISTORY_VISIBILITY_PERIOD - 1.day).ago.at_beginning_of_day

      where(Entry.arel_table[:timestamp].gteq(history_limit_date))
    end
  end

  alias_attribute :history, :entries

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

  def self.cached_count
    Rails.cache.fetch(cached_count_key, expires_in: 1.month) { count }
  end

  def self.reset_cached_count
    Rails.cache.delete(cached_count_key)
  end

  def self.cached_count_key
    "#{table_name}/count"
  end

  def to_param
    username
  end

  def to_s
    username
  end
end
