FROM elixir:1.7.1
WORKDIR /opt

RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list

RUN set -ex \
    && apt-get update \
    && apt-get install -y \
    apt-transport-https \
    build-essential \
    inotify-tools \
    libssl-dev \
    postgresql-client

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ADD .nvmrc .desired-node-version
RUN bash -l -c 'echo "installing Node.js via nvm" \
    && nvm --version \
    && nvm install $(cat .desired-node-version) \
    && nvm alias default $(cat .desired-node-version) \
    && nvm use default \
    && set -ex \
    && node --version \
    && npm --version && npm install -g yarn && yarn --version'

WORKDIR /opt/level

ADD *.exs *.lock *.config ./
RUN set -ex \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix compile

WORKDIR /opt/level/assets
ADD assets/package.json assets/yarn.lock ./
RUN bash -l -c 'yarn'

WORKDIR /opt/level

ADD . .

CMD ./script/docker-dev/entrypoint
