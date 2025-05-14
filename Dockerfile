# docker build --build-arg BASE=alpine:3.21
# docker build --build-arg BASE=mcr.microsoft.com/dotnet/sdk:9.0
ARG BASE=alpine:latest
FROM ${BASE}

# common
RUN apk update
RUN apk add bash build-base clang cmake curl git icu lsb-release-minimal perl python3 sudo tar wget

# dotnet
RUN curl -sSL --retry 5 https://dot.net/v1/dotnet-install.sh | sudo bash -eo pipefail /dev/stdin --channel 8.0 --install-dir /usr/share/dotnet
RUN curl -sSL --retry 5 https://dot.net/v1/dotnet-install.sh | sudo bash -eo pipefail /dev/stdin --version 9.0.203 --install-dir /usr/share/dotnet
RUN ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet

# sentry-native
RUN apk add bash cargo curl-dev libunwind-dev libunwind-static linux-headers openssl-dev python3-dev zlib-dev xz-dev
RUN apk add mitmproxy | true # optional (3.21+)

# sentry-dotnet
RUN apk add grpc-plugins openjdk11 powershell
ENV PROTOBUF_PROTOC=/usr/bin/protoc
ENV GRPC_PROTOC_PLUGIN=/usr/bin/grpc_csharp_plugin
RUN pwsh -Command Install-Module Pester -Force | true # optional (3.21+)
# mono only exists in alpine:edge (3.22+)
COPY aports /aports
RUN if ! apk add mono; then \
    apk add alpine-sdk abuild && \
    adduser root abuild && \
    mkdir -p ~/packages && \
    abuild-keygen -ain && \
    cd /aports/community/mono && \
    abuild -rF && \
    apk add --allow-untrusted ~/packages/community/x86_64/mono-6*.apk && \
    apk del alpine-sdk abuild && \
    rm -rf ~/packages; \
  fi
RUN mono --version
RUN rm -rf /aports

# system
RUN chmod -R 777 /opt
RUN chmod -R 777 /usr/share

# runner
RUN addgroup runner
RUN adduser -S -u 1001 -h /home/runner -G runner runner
RUN mkdir -p /home/runner /__e /__w /__w/_temp /__w/_actions /__w/_tool
RUN chown -R runner:runner /home/runner /__e /__w
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner
RUN chmod 0440 /etc/sudoers.d/runner
USER runner
WORKDIR /__w
ENTRYPOINT ["/bin/bash"]
