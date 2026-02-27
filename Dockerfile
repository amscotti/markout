# Build stage - Alpine with Crystal
FROM crystallang/crystal:latest-alpine AS builder

WORKDIR /app

# Install build dependencies for lexbor
RUN apk add --no-cache cmake make gcc g++ git

# Copy dependency files first for better caching
COPY shard.yml shard.lock ./
RUN shards install --production

# Copy source code
COPY src/ src/

# Build fully static binary
RUN crystal build src/markout_cli.cr -o markout --release --static --no-debug && \
    strip markout

# Runtime stage - Scratch (completely empty)
FROM scratch

# Copy CA certificates for HTTPS support (needed if fetching URLs)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary from builder
COPY --from=builder /app/markout /markout

# Use non-root user (numeric ID since Scratch has no /etc/passwd)
USER 65534:65534

ENTRYPOINT ["/markout"]
CMD ["--help"]
