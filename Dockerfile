# BASE IMAGE
FROM node:18-bullseye-slim as base

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        python3 && \
    rm -fr /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/*

RUN npm install --location=global --quiet npm truffle ganache

# TRUFFLE IMAGE
FROM base as truffle

RUN mkdir -p /home/app
WORKDIR /home/app

COPY package.json /home/app
COPY yarn.lock /home/app

RUN export GIT_SSL_NO_VERIFY=1 && \
        yarn install --quiet

COPY ./truffle-config.js /home/app
COPY ./src/contracts /home/app/contracts
COPY ./migrations /home/app/migrations/
COPY ./test /home/app/test/

CMD ["yarn", "test:stacktrace"]

# GANACHE IMAGE
FROM base as ganache

RUN mkdir -p /home
WORKDIR /home
COPY ./entrypoint.sh /home/app/entrypoint.sh
EXPOSE 8545

ENTRYPOINT ["/home/app/entrypoint.sh"]