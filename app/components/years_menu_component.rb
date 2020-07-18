class YearsMenuComponent < ViewComponent::Base
  def initialize(user:, years:, active_year:)
    @user = user
    @years_with_link_class = years.index_with { |year| "is-active" if active_year == year }
  end
end
