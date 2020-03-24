# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task qa: [:environment] do
  puts "\n== Running linters ==\n"
  sh "bundle exec rubocop"
  sh "bundle exec reek"
  sh "yarn eslint app/javascript"

  puts "\n== Running test suites ==\n"
  sh "bin/rails test -p"
  sh "bin/rails test:system"
end

task syncronize_users_data: [:environment] do
  puts "\n== Scheduling users data syncronization ==\n"
  
  UsersUpdateSchedulerJob.perform_now
end

