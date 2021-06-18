require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "validations" do
    should_not validate_presence_of(:avatar_url)
    should_not validate_presence_of(:checksum)
    should validate_presence_of(:time_zone)
    should_not validate_presence_of(:latitude)
    should_not validate_presence_of(:longitude)

    should validate_numericality_of(:latitude).allow_nil
    should validate_numericality_of(:longitude).allow_nil
  end
end
