class NotificationComponent < ViewComponent::Base
  def initialize(message:)
    @message = message
  end

  def render?
    @message.present?
  end
end
