Rails.application.configure do
  config.solid_errors.connects_to = { database: { writing: :ops, reading: :ops } }

  if Rails.env.production?
    config.solid_errors.username = Rails.application.credentials.dig(:admin, :username) || ""
    config.solid_errors.password = Rails.application.credentials.dig(:admin, :password) || ""
  end
end

ActiveSupport.on_load(:solid_errors_record) do
  include Purgeable

  purge after: 7.days
end
