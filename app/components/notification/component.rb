class Notification::Component < ViewComponent::Base
  def initialize(message:)
    super
    @message = message
  end

  def render?
    @message.present?
  end
end
