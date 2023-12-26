source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".tool-versions"

gem "rails", github: "rails/rails", branch: "main"

gem "bootsnap", require: false

gem "puma"

# Drivers
gem "redis" # Action Cable
gem "sqlite3"

# Queuing
gem "sidekiq"
gem "sidekiq-scheduler"

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
gem "rollbar"
gem "skylight", "~> 6.0.1", require: false

# Web Crawling
gem "ferrum"
gem "mechanize"

# Misc
gem "geocoder"
gem "gitlab-chronic"
gem "requestjs-rails"
gem "view_component"
gem "wheretz"
gem "kredis"

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
  gem "simplecov", "~> 0.17.1", require: false # https://github.com/codeclimate/test-reporter/issues/413
  gem "vcr"
  gem "webmock"
end
