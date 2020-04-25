class UserPresenter
  delegate :avatar_url, :username, to: :@user

  def initialize(user, activities)
    @user = user
    @activities = activities
  end

  def profile_url
    MAL::URLS.profile_url(@user.username)
  end

  def activities_per_date
    @activities.group_by(&:date)
  end

  def levels
    (0..4).index_with { |number| I18n.t("users.show.levels.#{number}") }
  end
end
