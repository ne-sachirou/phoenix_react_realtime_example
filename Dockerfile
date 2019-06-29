FROM nesachirou/elixir:1.8_erl22

SHELL ["/bin/ash", "-ex", "-o", "pipefail", "-c"]

RUN apk add --no-cache -t .build-deps \
    build-base \
    curl \
    git \
    nodejs \
    nodejs-npm \
    yaml-dev \
    zlib-dev \
 && rm -rf /var/cache/apk/*

WORKDIR /var/www
VOLUME /var/www

COPY mix.exs mix.lock ./
COPY apps/example/mix.exs apps/example/
COPY apps/example_web/assets/package.json apps/example_web/assets/package-lock.json apps/example_web/assets/
COPY apps/example_web/mix.exs apps/example_web/
RUN mix "do" deps.get, deps.compile \
 && MIX_ENV="test" mix deps.compile \
 && (cd apps/example_web/assets && npm ci) \
 && mv _build deps /tmp \
 && mv apps/example_web/assets/node_modules/ /tmp/example_web_node_modules

RUN apk add --no-cache -t .runtime-deps \
    inotify-tools \
    rsync \
 && rm -rf /var/cache/apk/*

EXPOSE 4000

CMD ["./entrypoint.sh"]
