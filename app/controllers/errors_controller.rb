class ErrorsController < ApplicationController
  def internal_error
    render(status: :internal_server_error)
  end

  def not_found
    render(status: :not_found)
  end
end
