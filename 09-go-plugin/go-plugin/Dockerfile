FROM golang:1.19-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the service
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o validator-service main.go

# Final stage
FROM alpine:latest

# Install ca-certificates and wget for health checks
RUN apk --no-cache add ca-certificates wget

WORKDIR /root/

# Copy the binary
COPY --from=builder /app/validator-service .

# Create non-root user
RUN adduser -D -g '' validator
USER validator

# Expose service port
EXPOSE 8002

# Add health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8002/health || exit 1

# Run the service
CMD ["./validator-service"]
