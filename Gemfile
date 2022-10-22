source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0.2"

gem "bootsnap", require: false
gem "ferrum"
gem "geocoder"
gem "gitlab-chronic"
gem "image_processing"
gem "lograge"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails", github: "rails/rails", ref: "fc9a1790333c1f7530f45e8716543148521f668b"
gem "rollbar"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "skylight", "~> 5.3.4"
gem "slim-rails"
gem "turbolinks"
gem "view_component"
gem "webpacker"
gem "wheretz"

group :development, :test do
  gem "jazz_fingers"
end

group :development do
  gem "brakeman"
  gem "listen"
  gem "rubocop"
  gem "rubocop-rails", require: false
  gem "web-console"
  gem "yard"
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
