source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.2.0"

gem "bootsnap", require: false
gem "ferrum"
gem "geocoder"
gem "gitlab-chronic"
gem "image_processing"
gem "lograge"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails", github: "rails/rails", branch: "main"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "skylight", "~> 5.3.4"
gem "slim-rails" # TODO: Abandon usage of slim and remove this gem
gem "view_component"
gem "wheretz"

# Make translations less brittle
gem "gettext", ">=3.0.2", require: false
gem "gettext_i18n_rails"

# Use JavaScript with ESM import maps
# [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Use Redis for Action Cable
gem "redis"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Integrate Dart Sass with the asset pipeline in Rails
gem "dartsass-rails"

gem "rollbar", require: false

group :development, :test do
  gem "debug"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "ruby_parser", require: false
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
