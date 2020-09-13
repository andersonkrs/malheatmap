source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "bootsnap", require: false
gem "chronic"
gem "google-cloud-storage", require: false
gem "image_processing"
gem "mechanize"
gem "pg"
gem "puma"
gem "rails"
gem "rollbar"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "slim-rails"
gem "turbolinks"
gem "view_component"
gem "webpacker"

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
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
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end
