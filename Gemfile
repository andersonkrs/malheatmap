source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "aws-sdk-s3", require: false
gem "bootsnap", require: false
gem "chronic"
gem "geocoder"
gem "image_processing"
gem "lograge"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails"
gem "rollbar"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "skylight"
gem "slim-rails"
gem "turbolinks"
gem "view_component"
gem "webpacker"
gem "wheretz"

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "jazz_fingers"
  gem "pry-byebug"
  gem "solargraph"
end

group :development do
  gem "brakeman"
  gem "listen"
  gem "rubocop"
  gem "rubocop-rails", require: false
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
