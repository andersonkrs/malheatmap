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

  class ActiveYearsTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
    end

    test "returns all years which user has activities" do
      create(:activity, user: @user, date: Date.new(2020, 1, 1))
      create(:activity, user: @user, date: Date.new(2019, 1, 1))
      create(:activity, user: @user, date: Date.new(2021, 1, 1))

      results = @user.active_years

      assert_equal [2021, 2020, 2019], results
    end

    test "caches query result" do
      create(:activity, user: @user, date: Date.new(2020, 1, 1))

      @user.active_years
      results = Rails.cache.read(@user.active_years_cache_key)

      assert_equal [2020], results
    end
  end
end
