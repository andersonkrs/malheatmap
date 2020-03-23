require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "parses avatar url with given page" do
    page = fake_page("user_profile.html")

    result = MAL::Parsers::Profile.new(page).parse

    assert_equal(
      { avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg" },
      result
    )
  end
end
