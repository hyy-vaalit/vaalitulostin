# Test/development image. The suite shells out to the psql CLI
# (\COPY seed import in lib/support/psql.rb), hence postgresql-client.
FROM ruby:3.4.6

RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Match Gemfile.lock BUNDLED WITH: the image's newer default bundler
# fails to materialize the lockfile (Could not find mini_portile2).
RUN gem install bundler -v 2.5.21 -N
ENV BUNDLER_VERSION=2.5.21

# Gems live in a named volume (see compose.yaml) so the mounted source
# tree stays clean and gems survive container recreation.
ENV BUNDLE_PATH=/bundle \
    BUNDLE_APP_CONFIG=/bundle/.config

WORKDIR /app
