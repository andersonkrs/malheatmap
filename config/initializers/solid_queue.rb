Rails.application.configure do
  config.solid_queue.connects_to = { database: { writing: :queues } }
  config.solid_queue.silence_polling = true
end
