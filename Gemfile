source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 7.2.0.beta3"

gem "bootsnap", require: false

gem "puma"

# Drivers
gem "sqlite3"
gem "activerecord-enhancedsqlite3-adapter"
gem "redis", ">= 4.0.1"

# Solid gems
gem "solid_queue"
gem "solid_errors"

# Queue management
gem "mission_control-jobs"

# Hotwire
gem "stimulus-rails"
gem "turbo-rails"

# Better i18n
gem "gettext", ">=3.0.2", require: false
gem "gettext_i18n_rails"

# Assets
gem "dartsass-rails"
gem "importmap-rails"
gem "propshaft"

# Media handler
gem "image_processing"

# Visibility
gem "lograge"
gem "newrelic_rpm"

# Web Crawling
gem "ferrum"
gem "mechanize"

# BI
gem "blazer"

# Backups
gem "aws-sdk-s3", require: false

# Misc
gem "geocoder"
gem "gitlab-chronic"
gem "requestjs-rails"
gem "view_component"
gem "wheretz"

group :development, :test do
  gem "debug"
  gem "rubocop-rails-omakase"
end

group :development do
  gem "brakeman"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "mocha"
  gem "simplecov", "~> 0.17.1", require: false # https://github.com/codeclimate/test-reporter/issues/413
  gem "vcr"
  gem "webmock"
end
