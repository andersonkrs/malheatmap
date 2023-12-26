ActiveSupport.on_load(:solid_cache_entry) { encrypts :value }

Rails.application.configure do
  config.solid_cache.connects_to = { database: { writing: :cache } }
  config.solid_cache.max_age = 60.days.to_i
  config.solid_cache.active_record_instrumentation = false
end
