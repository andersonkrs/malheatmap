require "test_helper"

class EntryTest < ActiveSupport::TestCase
  context "validations" do
    should validate_numericality_of(:amount).is_greater_than_or_equal_to(0)
    should validate_presence_of(:timestamp)
  end
end
