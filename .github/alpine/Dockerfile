# docker build --build-arg BASE=alpine:3.21
ARG BASE=alpine:latest
FROM ${BASE}

# common
RUN apk update
RUN apk add bash build-base clang cmake curl git icu lsb-release-minimal sudo tar wget
RUN curl -sSL --retry 5 https://dot.net/v1/dotnet-install.sh | sudo bash -eo pipefail /dev/stdin --channel 8.0 --install-dir /usr/share/dotnet
RUN ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet

# mono (3.22+)
RUN if ! apk add mono; then \
    sed -i.bak 's|/v3\.[0-9]\+|/edge|g' /etc/apk/repositories && \
    cat /etc/apk/repositories && \
    apk update && \
    apk add --no-cache mono && \
    mv /etc/apk/repositories.bak /etc/apk/repositories && \
    apk update; \
  fi
RUN mono --version

# sentry-native
RUN apk add cargo curl-dev libunwind-dev libunwind-static linux-headers openssl-dev perl python3-dev zlib-dev xz-dev
RUN apk add mitmproxy || true # optional (3.21+)

# sentry-dotnet
RUN apk add grpc-plugins openjdk11 powershell
ENV PROTOBUF_PROTOC=/usr/bin/protoc
ENV GRPC_PROTOC_PLUGIN=/usr/bin/grpc_csharp_plugin
RUN pwsh -Command Install-Module Pester -Scope AllUsers -Force || true # optional (3.21+)

# runner
RUN addgroup runner
RUN adduser -S -u 1001 -h /home/runner -G runner runner
RUN mkdir -p /home/runner /__e /__w /__w/_temp /__w/_actions /__w/_tool
RUN chown -R runner:runner /home/runner /__e /__w
RUN ln -s /__w /home/runner/work
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner
RUN chmod 0440 /etc/sudoers.d/runner
RUN chmod -R 777 /opt
RUN chmod -R 777 /usr/share
USER runner
WORKDIR /__w
ENTRYPOINT ["/bin/bash"]
