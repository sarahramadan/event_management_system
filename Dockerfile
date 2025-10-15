#############################################
# Multi-stage Dockerfile: development + production
#############################################
# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4.6
FROM registry.docker.com/library/ruby:${RUBY_VERSION}-slim AS base

# Create a non-root user and group that will own the application files
RUN groupadd --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 -m rails

ENV APP_HOME=/rails \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
WORKDIR ${APP_HOME}

# Common runtime libs
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libvips libpq5 curl bash ca-certificates && \
    rm -rf /var/lib/apt/lists/*

#############################################
# Development target
#############################################
FROM base AS development
ARG DEVELOPMENT_HOSTS=localhost,127.0.0.1
ENV DEVELOPMENT_HOSTS=$DEVELOPMENT_HOSTS
ENV RAILS_ENV=development RACK_ENV=development NODE_ENV=development \
    BUNDLE_WITH="development:test"
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config libyaml-dev less vim && \
    rm -rf /var/lib/apt/lists/*

# Grant ownership to the rails user before installing gems
RUN chown -R rails:rails ${APP_HOME} ${BUNDLE_PATH}
USER rails

COPY --chown=rails:rails Gemfile Gemfile.lock ./
RUN bundle install && bundle install --with development test && rm -rf ${BUNDLE_PATH}/ruby/*/cache
COPY --chown=rails:rails . .

# Normalize line endings & shebangs from Windows -> Linux
RUN chmod +x bin/* && sed -i 's/\r$//' bin/* && \
    grep -Ilr '^#!/usr/bin/env ruby.exe' bin | xargs -r sed -i 's|^#!/usr/bin/env ruby.exe|#!/usr/bin/env ruby|'

EXPOSE 3000
CMD ["./bin/rails","server","-b","0.0.0.0","-p","3000"]
