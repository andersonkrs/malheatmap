require "test_helper"

class EntryTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.local(2019, 10, 14, 12, 30)
  end

  test "parses all entry information from given page" do
    page = fake_page("user_manga_history.html")

    result = MAL::Parsers::Entry.new(page).parse

    assert_equal Time.zone.local(2019, 10, 13, 14, 4, 0, 0, 0), result[:timestamp]
    assert_equal 21, result[:item_id]
    assert_equal "Death Note", result[:item_name]
    assert_equal 108, result[:amount]
  end
end
