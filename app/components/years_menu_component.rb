class YearsMenuComponent < ViewComponent::Base
  attr_reader :user, :years, :selected_year

  def initialize(user:, years:, selected_year:)
    @user = user
    @years = years.sort.reverse
    @selected_year = selected_year
    super()
  end

  def link_for_year(year)
    link_to(year, user_path(user, year:), class: selected_year == year ? "is-active" : "")
  end
end
