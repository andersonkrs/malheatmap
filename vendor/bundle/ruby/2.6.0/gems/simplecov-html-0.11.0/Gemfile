# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", ">= 11"

# Use local copy of simplecov in development when checked out, fetch from git otherwise
if File.directory?(File.dirname(__FILE__) + "/../simplecov")
  gem "simplecov", :path => File.dirname(__FILE__) + "/../simplecov"
else
  gem "simplecov", :github => "colszowka/simplecov"
end

group :test do
  gem "minitest"
end

group :development do
  gem "rubocop"
  gem "sass"
  # sprockets 4.0 requires ruby 2.5+
  gem "sprockets", "~> 3.7"
end
