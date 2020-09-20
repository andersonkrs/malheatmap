release: bundle exec rails db:migrate
web: bundle exec rails server
worker: bundle exec sidekiq -q default -q active_storage_analysis -q active_storage_purge
worker_low: RAILS_MAX_THREADS=2 bundle exec sidekiq -q low
