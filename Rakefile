# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task qa: [:environment] do
  puts "== Running linters =="
  sh "bundle exec rubocop"
  sh "bundle exec reek"

  puts "== Running test suites =="
  sh "bin/rails test -p"
  sh "bin/rails test:system"
end
