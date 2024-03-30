Rails.application.configure do
  config.solid_errors.connects_to = { database: { writing: :ops, reading: :ops } }
  config.solid_errors.username = Rails.application.credentials.dig(:admin, :username) || ""
  config.solid_errors.password = Rails.application.credentials.dig(:admin, :password) || ""
end
