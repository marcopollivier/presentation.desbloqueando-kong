# Build stage
FROM rust:1.75-alpine AS builder

# Install dependencies
RUN apk add --no-cache musl-dev

WORKDIR /app

# Copy Cargo files
COPY Cargo.toml ./

# Create dummy source to cache dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies (this will create Cargo.lock)
RUN cargo build --release
RUN rm src/main.rs

# Copy real source code
COPY src/ ./src/

# Build application
RUN cargo build --release

# Runtime stage
FROM alpine:latest

# Install CA certificates and curl for health checks
RUN apk --no-cache add ca-certificates curl

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/target/release/server .

# Create non-root user
RUN addgroup -g 1001 -S rustapp && \
    adduser -S rustapp -u 1001

# Change ownership
RUN chown -R rustapp:rustapp /root
USER rustapp

# Expose port
EXPOSE 3003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3003/health || exit 1

# Start application
CMD ["./server"]
