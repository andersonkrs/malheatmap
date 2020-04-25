require "test_helper"

module UserPresenterTest
  class ActivitiesPerDateTest < ActiveSupport::TestCase
    setup do
      @user = build(:user)
      @activities = [
        build(:activity, date: Date.new(2020, 4, 1)),
        build(:activity, date: Date.new(2020, 4, 1)),
        build(:activity, date: Date.new(2020, 4, 2)),
        build(:activity, date: Date.new(2020, 4, 3))
      ]

      @presenter = UserPresenter.new(@user, @activities)
    end

    test "returns all activities grouped by date" do
      results = @presenter.activities_per_date

      assert_equal results[Date.new(2020, 4, 1)].size, 2
      assert_equal results[Date.new(2020, 4, 2)].size, 1
      assert_equal results[Date.new(2020, 4, 3)].size, 1
    end
  end

  class DelegationsTest < ActiveSupport::TestCase
    setup do
      @user = build(:user)
      @presenter = UserPresenter.new(@user, [])
    end

    test "delegates username to user object" do
      result = @presenter.username

      assert_equal result, @user.username
    end

    test "delegates avatar_url to user object" do
      result = @presenter.avatar_url

      assert_equal result, @user.avatar_url
    end
  end

  class LevelsTest < ActiveSupport::TestCase
    setup do
      @user = build(:user)
      @activities = build_list(:activity, 6)
      @presenter = UserPresenter.new(@user, @activities)
    end

    test "returns five levels with correct label each" do
      result = @presenter.levels

      assert_equal result, {
        0 => "None episodes/chapters watched/read on date",
        1 => "From 1 to 4 episodes/chapters watched/read on date",
        2 => "From 5 to 8 episodes/chapters watched/read on date",
        3 => "From 9 to 12 episodes/chapters watched/read on date",
        4 => "12+ episodes/chapters watched/read on date"
      }
    end
  end

  class ProfileUrlTest < ActiveSupport::TestCase
    setup do
      user = build(:user, username: "anderson")
      @presenter = UserPresenter.new(user, [])
    end

    test "returns mal profile url for given user" do
      result = @presenter.profile_url

      assert_equal result, "https://myanimelist.net/profile/anderson"
    end
  end
end
