require "application_system_test_case"

class AboutTest < ApplicationSystemTestCase
  test "renders without errors" do
    visit about_url

    assert_text "About"
    assert_text "Privacy"
    assert_text "Contact"
  end
end
