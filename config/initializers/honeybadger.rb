Honeybadger.configure do |config|
  config.api_key = Rails.application.credentials.honeybadger[:token]
end
