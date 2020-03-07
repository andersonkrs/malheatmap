require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "buils item url with given params" do
    assert_equal mal_item_url(:manga, 1), "https://myanimelist.net/manga/1"
    assert_equal mal_item_url(:anime, 2), "https://myanimelist.net/anime/2"
  end

  test "buils user profile URL with given username" do
    assert_equal mal_profile_url("andersonkrs"), "https://myanimelist.net/profile/andersonkrs"
  end
end
