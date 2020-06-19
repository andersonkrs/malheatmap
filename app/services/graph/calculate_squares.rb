module Graph
  class CalculateSquares < ApplicationService
    delegate :date_range, :activities, to: :context

    before_call do
      context.squares = []
    end

    def call
      date_range.each do |date|
        amount = grouped_activities.fetch(date, []).sum(&:amount)

        context.squares << GraphComponent::Square.new(date: date, amount: amount)
      end
    end

    private

    def grouped_activities
      @grouped_activities ||= activities.group_by(&:date)
    end
  end
end
