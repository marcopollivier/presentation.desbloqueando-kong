FROM kong:latest

# Copiar plugin customizado
COPY kong/plugins/request-validator /usr/local/share/lua/5.1/kong/plugins/request-validator

# Definir plugins disponíveis
ENV KONG_PLUGINS=bundled,request-validator

# Criar usuário kong se não existir
USER root
RUN addgroup -g 1000 kong 2>/dev/null || true
RUN adduser -D -G kong -u 1000 kong 2>/dev/null || true

USER kong
