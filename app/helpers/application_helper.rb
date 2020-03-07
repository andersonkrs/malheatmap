module ApplicationHelper
  module_function

  MAL_HOST = "myanimelist.net".freeze

  def mal_profile_url(username)
    URI::HTTPS.build(host: MAL_HOST, path: "/profile/#{username}").to_s
  end

  def mal_item_url(item_kind, item_id)
    URI::HTTPS.build(host: MAL_HOST, path: "/#{item_kind}/#{item_id}").to_s
  end
end
