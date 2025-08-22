FROM golang:1.19-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the plugin
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o plugin main.go

# Final stage
FROM alpine:latest

# Install ca-certificates for SSL
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary
COPY --from=builder /app/plugin .

# Expose plugin server port
EXPOSE 8002

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8002/status || exit 1

# Run the plugin
CMD ["./plugin"]
