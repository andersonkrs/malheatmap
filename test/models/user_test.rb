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

  class ActivitiesScopesTest
    class UniqueYearsTest < ActiveSupport::TestCase
      setup do
        @user = create(:user)
        create(:activity, user: @user, date: Date.new(2020, 1, 1))
        create(:activity, user: @user, date: Date.new(2019, 1, 1))
        create(:activity, user: @user, date: Date.new(2021, 1, 1))
      end

      test "returns all years which user has activities" do
        results = @user.activities.unique_years

        assert_equal [2021, 2020, 2019], results
      end
    end

    class ForDateRangeTest < ActiveSupport::TestCase
      setup do
        @user = create(:user)
        create(:activity, user: @user, date: Date.new(2020, 6, 11), item: create(:item, name: "Naruto"))
        create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "One Piece"))
        create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "Dragon Ball GT"))
        create(:activity, user: @user, date: Date.new(2020, 8, 11), item: create(:item, name: "Cowboy Bebop"))
        create(:activity, user: @user, date: Date.new(2020, 9, 11), item: create(:item, name: "Bleach"))
        create(:activity, date: Date.new(2020, 7, 11))
      end

      test "returns activities for the given date range" do
        results = @user.activities.for_date_range(Date.new(2020, 7, 11)..Date.new(2020, 8, 11)).map(&:name)

        assert 3, results.size
        assert_includes results, "Cowboy Bebop"
        assert_includes results, "Dragon Ball GT"
        assert_includes results, "One Piece"
      end
    end

    class OrderedAsTimelineTest < ActiveSupport::TestCase
      setup do
        @user = create(:user)
        create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "One Piece"))
        create(:activity, user: @user, date: Date.new(2020, 7, 11), item: create(:item, name: "Dragon Ball GT"))
        create(:activity, user: @user, date: Date.new(2020, 8, 11), item: create(:item, name: "Cowboy Bebop"))
      end

      test "returns records ordered by date desc and name asc" do
        results = @user.activities.ordered_as_timeline.to_a

        assert_equal results.first.date, Date.new(2020, 8, 11)
        assert_equal results.first.name, "Cowboy Bebop"
        assert_equal results.second.date, Date.new(2020, 7, 11)
        assert_equal results.second.name, "Dragon Ball GT"
        assert_equal results.third.date, Date.new(2020, 7, 11)
        assert_equal results.third.name, "One Piece"
      end
    end
  end

  class EntriesScopesTest
    class VisibleToUserOnMalTest < ActiveSupport::TestCase
      setup do
        @user = create(:user)
      end

      test "returns entries from the last three weeks" do
        create(:entry)
        create(:entry, user: @user, timestamp: 22.days.ago)
        entry1 = create(:entry, user: @user, timestamp: 2.days.ago)
        entry2 = create(:entry, user: @user, timestamp: 5.days.ago)

        results = @user.history.visible_to_user_on_mal.pluck(:id)

        assert_equal results.sort, [entry1.id, entry2.id].sort
      end
    end
  end
end
