class AdminController < ApplicationController
  if Rails.env.production?
    http_basic_authenticate_with(
      name: "admin",
      password: Rails.application.credentials.dig(:admin, :password) || ""
    )
  end
end
