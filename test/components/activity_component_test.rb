require "test_helper"

class ActivityComponentTest < ViewComponent::TestCase
  setup do
    @manga_activity = Activity.new(item: items(:one_piece), amount: 10)
    @anime_activity = Activity.new(item: items(:cowboy_bebop), amount: 2)
  end

  test "renders manga activity correctly" do
    component = render_inline(ActivityComponent.new(activity: @manga_activity))

    assert_includes component.css("a").attribute("href").value, "https://myanimelist.net/manga"
    assert_equal "fas fa-book-reader", component.css("i").attribute("class").value
    assert_includes component.text, @manga_activity.name
    assert_includes component.text, "10 chapters"
  end

  test "renders anime activity correctly" do
    component = render_inline(ActivityComponent.new(activity: @anime_activity))

    assert_includes component.css("a").attribute("href").value, "https://myanimelist.net/anime"
    assert_equal "fas fa-tv", component.css("i").attribute("class").value
    assert_includes component.text, @anime_activity.name
    assert_includes component.text, "2 episodes"
  end
end
