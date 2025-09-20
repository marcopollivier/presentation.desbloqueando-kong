FROM kong:latest

# Copiar plugin de demonstração
COPY kong/plugins/lua-demo /usr/local/share/lua/5.1/kong/plugins/lua-demo

# Instalar ferramentas para demonstração
USER root
RUN apt-get update && apt-get install -y curl wget htop && rm -rf /var/lib/apt/lists/*

# Definir plugins disponíveis
ENV KONG_PLUGINS=bundled,lua-demo

USER kong
