# docker build --build-arg BASE=alpine:3.21
ARG BASE=alpine:latest
FROM ${BASE}

RUN apk update

# mono only exists in alpine:edge (3.22+)
RUN if ! apk add mono; then \
    sed -i.bak 's|/v3\.[0-9]\+|/edge|g' /etc/apk/repositories && \
    cat /etc/apk/repositories && \
    apk update && \
    apk add --no-cache mono && \
    mv /etc/apk/repositories.bak /etc/apk/repositories && \
    apk update; \
  fi

RUN mono --version
