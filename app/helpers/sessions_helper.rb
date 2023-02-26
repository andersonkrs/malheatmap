module SessionsHelper
  def signed_in?
    Current.user.present?
  end
end
