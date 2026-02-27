# Build stage
FROM crystallang/crystal:latest AS builder

WORKDIR /build

# Install build dependencies for lexbor
RUN apt-get update && apt-get install -y cmake git && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY shard.yml shard.lock ./
RUN shards install --production

# Update ldconfig to find lexbor library
RUN echo "/build/lib/lexbor/src/ext/lexbor-c/build" > /etc/ld.so.conf.d/lexbor.conf && ldconfig

# Copy source code
COPY . .

# Build binary using shared library instead of static
# The static library has linking issues, use shared library with proper rpath
RUN crystal build src/markout_cli.cr -o markout --release --no-debug \
    --link-flags "-Wl,-rpath,/build/lib/lexbor/src/ext/lexbor-c/build -L/build/lib/lexbor/src/ext/lexbor-c/build -llexbor"

# Runtime stage - minimal debian image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /build/markout /usr/local/bin/markout

# Copy shared library and update ldconfig
COPY --from=builder /build/lib/lexbor/src/ext/lexbor-c/build/liblexbor.so* /usr/local/lib/
RUN ldconfig

# Create non-root user
RUN useradd -m -s /bin/sh markout

USER markout

ENTRYPOINT ["markout"]
CMD ["--help"]
