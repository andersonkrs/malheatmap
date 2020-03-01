require "test_helper"

module Parsers
  class ProfileTest < ActiveSupport::TestCase
    test "parses avatar url with given page" do
      page = fake_page("user_profile.html")

      result = Profile.call(page)

      assert_equal(
        { avatar_url: "https://cdn.myanimelist.net/images/userimages/7868083.jpg" },
        result
      )
    end
  end
end
