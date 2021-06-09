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

  class ActiveYearsTest < ActiveSupport::TestCase
    test "returns the years range since the user has subscribed or had recorded the first activity" do
      travel_to Date.new(2021, 1, 1)
      user = User.create!(username: "random1")
      assert_equal (2021..2021), user.active_years

      travel_to Date.new(2017, 10, 15)
      user = User.create!(username: "random2")
      travel_to Date.new(2021, 1, 1)
      assert_equal (2017..2021), user.active_years

      user.activities.create!(item: items(:naruto), amount: 1, date: Date.new(2016, 12, 30))
      user = User.find(user.id)
      assert_equal (2016..2021), user.active_years
    end
  end
end
