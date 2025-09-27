# Multi-stage build para Go
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copiar código fonte
COPY main.go ./

# Build da aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Imagem final minimalista
FROM alpine:latest

RUN apk --no-cache add ca-certificates curl

WORKDIR /root/

# Copiar binário do stage builder
COPY --from=builder /app/main .

# Expor porta
EXPOSE 8080

# Comando padrão
CMD ["./main"]
