require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "validations" do
    should_not validate_presence_of(:avatar_url)
    should_not validate_presence_of(:checksum)
  end
end
