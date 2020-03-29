require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  context "validations" do
    should validate_numericality_of(:amount).is_greater_than_or_equal_to(0)
    should validate_presence_of(:date)
  end

  context "associations" do
    should belong_to :user
    should belong_to :item
  end
end
