# syntax = docker/dockerfile:1

# Make sure it matches the Ruby version in .tool-versions and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim as base

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

# Install packages need to build gems
RUN apt-get update -qq && \
    apt-get install -y build-essential git pkg-config redis

# Install application gems
COPY .tool-versions Gemfile Gemfile.lock ./
RUN bundle install && bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl \
                                               wget \
                                               iputils-ping \
                                               gnupg \
                                               gnupg2 \
                                               gnupg1 \
                                               libvips \
                                               imagemagick \
                                               redis && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV CHROME_VERSION="119.0.6045.199-1"

RUN wget --no-check-certificate https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
    (dpkg -i google-chrome-stable_${CHROME_VERSION}_amd64.deb || true) && \
    apt-get update -qq && \
    apt-get -y -f install

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
