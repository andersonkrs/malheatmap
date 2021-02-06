source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 2.7.2"

gem "aws-sdk-s3", require: false
gem "bootsnap", require: false
gem "geocoder"
gem "gitlab-chronic"
gem "image_processing"
gem "lograge"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails", "~> 6.1.1"
gem "rollbar"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "skylight", "~> 5.0.0.beta5"
gem "slim-rails"
gem "turbolinks"
gem "view_component"
gem "webpacker"
gem "wheretz"

group :development, :test do
  gem "faker"
  gem "jazz_fingers"
end

group :development do
  gem "brakeman"
  gem "listen"
  gem "rubocop"
  gem "rubocop-rails", require: false
  gem "solargraph"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "imatcher"
  gem "selenium-webdriver"
  gem "shoulda"
  gem "simplecov", "~> 0.17.1", require: false # https://github.com/codeclimate/test-reporter/issues/413
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end
