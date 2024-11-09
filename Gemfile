source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 8.0.0"

gem "bootsnap", require: false

gem "puma"

# Drivers
gem "sqlite3", "~> 2.1.0"
gem "redis", ">= 4.0.1"

# SSL, HTTP2
gem "thruster"

# Deployment
gem "kamal"

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

# Web Crawling
gem "ferrum"
gem "mechanize"

# BI
gem "blazer"

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
