module Authentication
  extend ActiveSupport::Concern

  included { before_action :authenticate }

  private

  def authenticate
    Current.user = User.find_by(id: session[:current_user_id])
  end
end
