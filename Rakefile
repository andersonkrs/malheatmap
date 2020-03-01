# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task qa: [:environment] do
  sh "rubocop"
  sh "reek"
  sh "rails test -p"
  sh "rails test:system"
end
