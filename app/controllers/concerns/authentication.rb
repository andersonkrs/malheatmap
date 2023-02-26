module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  private

  def authenticate
    Current.user = User.find_by(id: session[:current_user_id])
  end
end
