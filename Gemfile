source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", github: "rails/rails", branch: "main"

gem "bootsnap", require: false

gem "puma"

# Deployment
gem "kamal"

# HTTP2, SSL, Caching
gem "thruster"

# Drivers
gem "redis" # Action Cable
gem "sqlite3"
gem "activerecord-enhancedsqlite3-adapter"

# Queuing
gem "solid_queue"
gem "mission_control-jobs"

# Cache
gem "solid_cache"

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
