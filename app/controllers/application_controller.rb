class ApplicationController < ActionController::Base
  def about
    render "application/about"
  end

  def faq
    render "application/faq"
  end

  def internal_error
    render "application/internal_error", status: :internal_server_error
  end

  def not_found
    render "application/not_found", status: :not_found
  end
end
