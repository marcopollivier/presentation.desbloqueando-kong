FROM golang:1.21-alpine AS builder

# Instalar dependências
RUN apk add --no-cache git

# Configurar diretório de trabalho
WORKDIR /app

# Copiar arquivos de configuração Go
COPY go-lua-host/go.mod go-lua-host/go.sum ./
RUN go mod download

# Copiar código fonte
COPY go-lua-host/ ./
RUN go build -o lua-embedding-demo main.go

# Imagem final
FROM alpine:latest

# Instalar dependências runtime
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copiar binário compilado
COPY --from=builder /app/lua-embedding-demo .

# Copiar scripts Lua
COPY lua-scripts/ ./lua-scripts/
COPY examples/ ./examples/

# Tornar binário executável
RUN chmod +x lua-embedding-demo

# Comando padrão
CMD ["./lua-embedding-demo", "basic"]
