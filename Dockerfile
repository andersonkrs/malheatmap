# syntax = docker/dockerfile:1

# Make sure it matches the Ruby version in .tool-versions and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-alpine3.18 as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true" \
    FERRUM_DEFAULT_TIMEOUT="15" \
    FERRUM_PROCESS_TIMEOUT="30"

# Throw-away build stage to reduce size of final image
FROM base as build

RUN apk add --update --no-cache \
  build-base \
  git \
  curl \
  tzdata \
  sqlite-dev

# Install application gems
COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install && bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install dependencies:
# - tzdata: Timezones
# - libxml2 libxslt1 gcompat: Nokogiri
# - vips: ActiveStorage
# - aws-cli zip Backups
RUN apk add --update --no-cache \
  bash curl \
  tzdata \
  sqlite-dev \
  chromium \
  redis \
  libxml2 libxslt gcompat \
  vips \
  aws-cli zip

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
