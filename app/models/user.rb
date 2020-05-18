class User < ApplicationRecord
  has_many :entries, dependent: :destroy, inverse_of: :user
  has_many :activities, dependent: :destroy, inverse_of: :user

  def to_param
    username
  end

  def active_years
    Rails.cache.fetch(active_years_cache_key, expires_in: 12.hours.from_now) do
      activities
        .select("date_part('year', date) as year")
        .reorder("year DESC")
        .distinct
        .map { |record| record.year.to_i }
    end
  end

  def active_years_cache_key
    "#{cache_key_with_version}/active-years"
  end
end
