release: bundle exec rails db:migrate
web: bundle exec rails server
worker: bundle exec sidekiq -q default
worker_low: bundle exec sidekiq -q low -c 2
