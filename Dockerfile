# Multi-stage image:
#   dev        — development and tests via compose.yaml: source is
#                bind-mounted, gems live in a named volume
#   production — self-contained: gems, code and precompiled assets baked in
#                  docker build --target production -t vaalitulostin .
ARG RUBY_VERSION=4.0.5
FROM ruby:${RUBY_VERSION} AS base

# psql CLI: the test suite shells out to it (\COPY seed import in
# lib/support/psql.rb); also handy for rails dbconsole.
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Match Gemfile.lock BUNDLED WITH.
RUN gem install bundler -v 4.0.10 -N
ENV BUNDLER_VERSION=4.0.10

WORKDIR /app

# --- Development / test ---
# Gems live in a named volume (see compose.yaml) so the mounted source
# tree stays clean and gems survive container recreation.
FROM base AS dev
ENV BUNDLE_PATH=/bundle \
    BUNDLE_APP_CONFIG=/bundle/.config

# --- Production ---
FROM base AS production
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# The app hard-requires its runtime env at boot (config/initializers/000_vaalit.rb),
# and assets:precompile boots the app — feed it throwaway values.
RUN SECRET_KEY_BASE_DUMMY=1 \
    SITE_ADDRESS=https://example.invalid \
    EMAIL_FROM_ADDRESS=build@example.invalid \
    EMAIL_FROM_NAME=build \
    AWS_S3_BUCKET_NAME=build \
    AWS_S3_BASE_URL=s3.amazonaws.com \
    AWS_S3_ACCESS_KEY_ID=build \
    AWS_SECRET_ACCESS_KEY=build \
    RESULT_ADDRESS=https://example.invalid \
    ROLLBAR_ACCESS_TOKEN=build \
    VOTING_API_JWT_APIKEY=build \
    VOTING_API_BASE_URL=https://localhost \
    VOTING_API_SESSION_LINK_ENDPOINT=/ \
    VOTING_API_VOTERS_ENDPOINT=/ \
    VOTING_API_VOTES_ENDPOINT=/ \
    VOTING_API_SUMMARY_ENDPOINT=/ \
    bundle exec rake assets:precompile

RUN useradd --create-home --shell /usr/sbin/nologin rails \
 && mkdir -p log tmp \
 && chown -R rails:rails log tmp
USER rails

EXPOSE 3000
# Procfile worker runs on the same image: bundle exec rake jobs:work
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
