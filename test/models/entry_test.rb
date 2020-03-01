require "test_helper"

class EntryTest < ActiveSupport::TestCase
  context "validations" do
    should validate_numericality_of(:amount).is_greater_than_or_equal_to(0)
    should validate_numericality_of(:item_id).is_greater_than(0)
    should validate_presence_of(:item_name)
    should validate_presence_of(:item_kind)
    should validate_presence_of(:timestamp)
  end

  test "returns manga item url when entry is a manga" do
    entry = build(:entry, item_kind: :manga, item_id: 1)

    assert_equal entry.item_url, "https://myanimelist.net/manga/1"
  end

  test "returns anime item url when entry is an anime" do
    entry = build(:entry, item_kind: :anime, item_id: 2)

    assert_equal entry.item_url, "https://myanimelist.net/anime/2"
  end
end
