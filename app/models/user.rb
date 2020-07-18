class User < ApplicationRecord
  has_one_attached :signature

  has_many :entries, dependent: :delete_all, inverse_of: :user do
    def visible_to_user_on_mal
      where("timestamp >= ?", MAL::USER_HISTORY_VISIBILITY_PERIOD.ago.at_beginning_of_day.in_time_zone)
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

  def to_param
    username
  end
end
