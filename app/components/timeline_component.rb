class TimelineComponent < ViewComponent::Base
  def initialize(activities:)
    @activities = activities
    super()
  end

  def header?(date)
    @activities.first.date.beginning_of_month == date.beginning_of_month
  end

  def footer?(date)
    @activities.last.date.beginning_of_month == date.beginning_of_month
  end

  def activities_by_month_and_date
    @activities
      .group_by { |activity| activity.date.beginning_of_month }
      .transform_values { |activities| activities.group_by(&:date) }
  end
end
