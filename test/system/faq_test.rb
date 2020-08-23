require "application_system_test_case"

class FAQTest < ApplicationSystemTestCase
  test "renders without errors" do
    visit faq_url

    assert_text "FAQ"
  end
end
