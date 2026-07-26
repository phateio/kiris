FROM ruby:2.5.9-slim

COPY sources.list /etc/apt/sources.list

WORKDIR /usr/src/app
ENV RAILS_ENV=production

# Dependencies first, so the bundle layer is reused when only app code changes.
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ruby-dev \
    libpq-dev \
    nodejs \
    && bundle install \
    && rm -rf /var/lib/apt/lists/*

COPY . .
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "puma"]
