module MAL
  module URLS
    module_function

    MAL_HOST = "myanimelist.net".freeze

    def profile_url(username)
      URI::HTTPS.build(host: MAL_HOST, path: "/profile/#{username}").to_s
    end

    def anime_url(anime_id)
      item_url(:anime, anime_id)
    end

    def manga_url(manga_id)
      item_url(:manga, manga_id)
    end

    private

    def item_url(item_kind, item_id)
      URI::HTTPS.build(host: MAL_HOST, path: "/#{item_kind}/#{item_id}").to_s
    end
  end
end
