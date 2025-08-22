FROM kong:3.4-alpine

# Copiar plugin de demonstração
COPY kong/plugins/lua-demo /usr/local/share/lua/5.1/kong/plugins/lua-demo

# Instalar ferramentas para demonstração
USER root
RUN apk add --no-cache curl wget htop

# Definir plugins disponíveis
ENV KONG_PLUGINS=bundled,lua-demo

USER kong
