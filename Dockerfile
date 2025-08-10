FROM ruby:3.3.0-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client build-essential libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 3000

# Copia o entrypoint.sh para dentro do container
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["rails", "server", "-b", "0.0.0.0"]
