module MAL
  module URLS
    module_function

    def oauth_authorize_url(**query)
      URI::HTTPS.build(host: HOST, path: "/v1/oauth2/authorize", query: query.to_query).to_s
    end

    def profile_url(username)
      URI::HTTPS.build(host: HOST, path: "/profile/#{username}").to_s
    end

    def anime_url(anime_id)
      item_url(:anime, anime_id)
    end

    def manga_url(manga_id)
      item_url(:manga, manga_id)
    end

    def base_api_url
      URI::HTTPS.build(host: HOST, path: "/v1").to_s
    end

    private

    def item_url(item_kind, item_id)
      URI::HTTPS.build(host: HOST, path: "/#{item_kind}/#{item_id}").to_s
    end
  end
end
