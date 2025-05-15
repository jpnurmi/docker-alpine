# docker build --build-arg BASE=alpine:3.21
ARG BASE=alpine:latest
FROM ${BASE}

RUN apk update
COPY aports ~/aports
RUN if ! apk add mono; then \
    apk add --no-cache alpine-sdk abuild && \
    adduser root abuild && \
    mkdir -p ~/packages && \
    abuild-keygen -ain && \
    cd ~/aports && \
    abuild -rF && \
    apk add --allow-untrusted ~/packages/community/x86_64/mono-6*.apk && \
    apk del alpine-sdk abuild && \
    rm -rf ~/packages; ~/.abuild \
  fi
RUN rm -rf ~/aports
RUN mono --version
