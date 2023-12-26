source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".tool-versions"

gem "rails", github: "rails/rails", branch: "main"

gem "bootsnap", require: false
gem "ferrum"
gem "geocoder"
gem "gitlab-chronic"
gem "lograge"
gem "mechanize"
gem "puma"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "view_component"
gem "wheretz"

# Drivers
gem "pg"
gem "redis" # Use Redis for Action Cable
gem "sqlite3" # Cache, queueing

# Cache
gem "solid_cache"

# Make translations less brittle
gem "gettext", ">=3.0.2", require: false
gem "gettext_i18n_rails"

# Assets
gem "dartsass-rails"
gem "importmap-rails"
gem "propshaft"

# Media handler
gem "image_processing"

# Hotwire
gem "stimulus-rails"
gem "turbo-rails"

# Visibility
gem "newrelic_rpm"
gem "rollbar"
gem "skylight", "~> 6.0.1", require: false

group :development, :test do
  gem "debug"
  gem "rubocop-performance"
  gem "rubocop-rails"
end

group :development do
  gem "brakeman"
  gem "syntax_tree", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "imatcher"
  gem "mocha"
  gem "shoulda"
  gem "simplecov", "~> 0.17.1", require: false # https://github.com/codeclimate/test-reporter/issues/413
  gem "vcr"
  gem "webmock"
end
