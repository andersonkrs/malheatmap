source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 7.2.0.beta1"

gem "bootsnap", require: false

gem "puma"

# Drivers
gem "redis" # Action Cable
gem "sqlite3"
gem "activerecord-enhancedsqlite3-adapter"

# Queuing
gem "solid_queue", github: "rails/solid_queue", branch: "main"
gem "mission_control-jobs"

# Cache
# Rails 7.2 hotfix
gem "solid_cache", github: "npezza93/solid_cache", branch: "main"

# Hotwire
gem "stimulus-rails", github: "hotwired/stimulus-rails", branch: "main"
gem "turbo-rails", github: "hotwired/turbo-rails", branch: "main"

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
gem "solid_errors"

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
