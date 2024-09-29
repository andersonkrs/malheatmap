Rails.application.configure do
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.silence_polling = true
end
