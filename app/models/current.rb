# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user

  resets { Time.zone = nil }

  def user=(user)
    super
    Time.zone = user&.time_zone || "UTC"
  end
end
