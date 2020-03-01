Rails.application.config.generators do |config|
  config.orm :active_record, primary_key_type: :uuid
end
