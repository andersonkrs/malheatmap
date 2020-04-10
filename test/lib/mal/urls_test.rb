require "test_helper"

class URLSTest < ActiveSupport::TestCase
  include MAL::URLS

  test "builds anime url with given id" do
    assert_equal anime_url(2), "https://myanimelist.net/anime/2"
  end

  test "builds manga url with given id" do
    assert_equal manga_url(1), "https://myanimelist.net/manga/1"
  end

  test "builds user profile URL with given username" do
    assert_equal profile_url("andersonkrs"), "https://myanimelist.net/profile/andersonkrs"
  end
end
