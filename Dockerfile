# syntax = docker/dockerfile:1

# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.0
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true"
    RAILS_LOG_TO_STDOUT="true" \


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages need to build gems
RUN apt-get update -qq && \
    apt-get install -y build-essential git libpq-dev pkg-config redis

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && bundle exec bootsnap precompile --gemfile


# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM ruby:$RUBY_VERSION-alpine

RUN apk add --no-cache \
            --repository http://dl-3.alpinelinux.org/alpine/edge/community \
            --repository http://dl-3.alpinelinux.org/alpine/edge/main \
            chromium \
            curl \
            postgresql-dev \
            redis \
            vips-dev \
            libxml2 \
            libxslt \
            imagemagick

# Set chromium path for generating images
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
