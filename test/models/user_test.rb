require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:entries).dependent(:destroy).inverse_of(:user)
    should have_many(:activities).dependent(:destroy).inverse_of(:user)
  end

  context "validations" do
    should_not validate_presence_of(:avatar_url)
    should_not validate_presence_of(:checksum)
  end
end
