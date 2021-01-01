class YearsMenuComponent < ViewComponent::Base
  def initialize(user:, years:, active_year:)
    super
    @user = user
    @years_with_link_class = years.sort.reverse.index_with { |year| "is-active" if active_year == year }
  end
end
