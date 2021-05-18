class ActivityComponent < ViewComponent::Base
  include MAL::URLS

  attr_reader :activity, :url, :icon_class, :amount

  delegate :mal_id, :name, :kind, :date, to: :activity

  def initialize(activity:)
    super
    if activity.item.anime?
      @url = anime_url(mal_id)
      @icon_class = "fas fa-tv"
      @amount = I18n.t("users.activity.episodes", count: @activity.amount)
    else
      @url = manga_url(mal_id)
      @icon_class = "fas fa-book-reader"
      @amount = I18n.t("users.activity.chapters", count: @activity.amount)
    end
  end
end
