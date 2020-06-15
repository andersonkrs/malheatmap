class ActivityComponent < ViewComponent::Base
  include MAL::URLS

  attr_reader :activity
  delegate :mal_id, :name, :kind, :date, to: :activity

  def initialize(activity:)
    @activity = activity
  end

  def url
    if activity.item.anime?
      anime_url(mal_id)
    else
      manga_url(mal_id)
    end
  end

  def icon_class
    activity.item.anime? ? "fas fa-tv" : "fas fa-book-reader"
  end

  def amount
    I18n.t("users.activity.episodes", count: activity.amount)
  end
end
