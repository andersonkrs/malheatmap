class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to :not_found
  end
end
