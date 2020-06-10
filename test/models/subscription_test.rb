require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:username)
  end
end
