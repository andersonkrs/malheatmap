require "test_helper"

def presenter
  ActivityPresenter.new(@activity)
end

class ActivityPresenterTest < ActiveSupport::TestCase
  class IconTest < ActiveSupport::TestCase
    test "returns correct icon class for manga activity" do
      @activity = create(:activity, :manga)

      result = presenter.icon_class

      assert_equal result, "fas fa-book-reader"
    end

    test "returns correct icon class for anime activity" do
      @activity = create(:activity, :anime)

      result = presenter.icon_class

      assert_equal result, "fas fa-tv"
    end
  end

  class NameTest < ActiveSupport::TestCase
    setup do
      @activity = create(:activity)
    end

    test "returns activity item name" do
      result = presenter.name

      assert_equal result, @activity.name
    end
  end

  class AmountTest < ActiveSupport::TestCase
    test "returns correct amount text for manga activity" do
      @activity = create(:activity, :manga, amount: 2)
      result = presenter.amount

      assert_equal result, "2 chapters"
    end

    test "returns correct amount text for anime activity" do
      @activity = create(:activity, :anime, amount: 2)
      result = presenter.amount

      assert_equal result, "2 episodes"
    end
  end
end
