namespace :db do
  desc "Vacuum databases"
  task vacuum: [:environment] do
    Rails.logger.info("Pausing queues...")
    ApplicationJob.queues.each(&:pause)

    databases = Rails.application.config.database_configuration[Rails.env]

    databases.each do |name, config|
      SQLite3::Database.new(config["database"]) do |db|
        Rails.logger.info("Running VACUUM on: #{name}")
        db.execute("VACUUM")
      end
    end

    Rails.logger.info("VACUUM completed!")
  ensure
    ApplicationJob.queues.each(&:resume)
    Rails.logger.info("Queues resume!")
  end
end
