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
gem "rails", "~> 6.1.3"
gem "rollbar"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "skylight", "~> 5.0.1"
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
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
  gem "yard"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "imatcher"
  gem "shoulda"
  gem "simplecov", "~> 0.17.1", require: false # https://github.com/codeclimate/test-reporter/issues/413
  gem "vcr"
  gem "webmock"
end
