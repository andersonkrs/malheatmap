ENV["BLAZER_USERNAME"] = Rails.application.credentials.dig(:admin, :username) || ""
ENV["BLAZER_PASSWORD"] = Rails.application.credentials.dig(:admin, :password) || ""
