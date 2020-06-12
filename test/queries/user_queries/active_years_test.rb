require "test_helper"

module UserQueries
  class ActiveYearsTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
    end

    test "returns all years which user has activities" do
      create(:activity, user: @user, date: Date.new(2020, 1, 1))
      create(:activity, user: @user, date: Date.new(2019, 1, 1))
      create(:activity, user: @user, date: Date.new(2021, 1, 1))

      results = ActiveYears.execute(user: @user)

      assert_equal [2021, 2020, 2019], results
    end
  end
end
