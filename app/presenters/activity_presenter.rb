class ActivityPresenter < ApplicationPresenter
  delegate :icon_class, :amount, :link, to: :item_presenter
  delegate :name, :kind, to: :activity

  def initialize(activity)
    @activity = activity
  end

  private

  attr_reader :activity

  def item_presenter
    @item_presenter ||= item_presenter_klass.new(activity)
  end

  def item_presenter_klass
    if activity.item.anime?
      AnimeItemPresenter
    else
      MangaItemPresenter
    end
  end

  class AnimeItemPresenter
    include MAL::URLS

    def initialize(activity)
      @activity = activity
    end

    def icon_class
      "fas fa-tv"
    end

    def link
      anime_url(@activity.mal_id)
    end

    def amount
      I18n.t("users.activity.episodes", count: @activity.amount)
    end
  end

  class MangaItemPresenter
    include MAL::URLS

    def initialize(activity)
      @activity = activity
    end

    def icon_class
      "fas fa-book-reader"
    end

    def link
      manga_url(@activity.mal_id)
    end

    def amount
      I18n.t("users.activity.chapters", count: @activity.amount)
    end
  end
end
