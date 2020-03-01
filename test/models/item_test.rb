require "test_helper"

class ItemTest < ActiveSupport::TestCase
  context "validations" do
    should validate_numericality_of(:mal_id).is_greater_than(0)
    should validate_presence_of(:name)
    should validate_presence_of(:kind)
  end
end
