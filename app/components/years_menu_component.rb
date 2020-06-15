class YearsMenuComponent < ViewComponent::Base
  def initialize(user:, years:, active_year:)
    @user = user
    @years = years.map { |year| [year, active_year == year] }.to_h
  end
end
