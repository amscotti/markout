# Build stage
FROM crystallang/crystal:latest-alpine AS builder

WORKDIR /build

# Install dependencies
COPY shard.yml shard.lock ./
RUN shards install --production

# Copy source code
COPY . .

# Build static binary
RUN crystal build src/markout_cli.cr -o markout --release --static --no-debug

# Runtime stage - minimal image
FROM alpine:latest

RUN apk add --no-cache ca-certificates

# Copy binary from builder
COPY --from=builder /build/markout /usr/local/bin/markout

# Create non-root user
RUN adduser -D -s /bin/sh markout

USER markout

ENTRYPOINT ["markout"]
CMD ["--help"]
