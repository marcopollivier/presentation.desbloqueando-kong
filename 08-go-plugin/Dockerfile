FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o simple-go-plugin main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN addgroup -g 1000 kong && adduser -D -u 1000 -G kong kong
WORKDIR /usr/local/kong
COPY --from=builder /app/simple-go-plugin .
RUN chmod +x simple-go-plugin
RUN chown -R kong:kong /usr/local/kong
USER kong
CMD ["./simple-go-plugin"]