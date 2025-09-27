# Tecnologias e Dependências - Kong Gateway Workshop

## 🎯 Visão Geral

Este documento cataloga todas as **tecnologias, dependências e ferramentas** utilizadas no Kong Gateway Workshop, incluindo versões recomendadas, propósito e configurações específicas.

## 🏗️ Stack Principal

### Core Infrastructure

| Componente | Versão | Propósito | Configuração |
|------------|--------|-----------|--------------|
| **Kong Gateway** | `3.4+` | API Gateway principal | Modo declarativo via `kong.yml` |
| **Docker** | `24.0+` | Containerização | Engine + Compose V2 |
| **Docker Compose** | `2.20+` | Orquestração local | Multi-service stacks |

### Observabilidade Stack

| Componente | Versão | Propósito | Porta Padrão |
|------------|--------|-----------|--------------|
| **Prometheus** | `2.47+` | Coleta de métricas | `:9090` |
| **Grafana** | `10.1+` | Visualização de dados | `:3000` |
| **Kong Prometheus Plugin** | Nativo | Exposição de métricas | `/metrics` |

### Linguagens e Runtimes

| Linguagem | Versão | Uso no Projeto | Projetos |
|-----------|--------|----------------|----------|
| **Lua** | `5.1` (LuaJIT) | Kong plugins customizados | `06-custom-plugin` |
| **Go** | `1.21+` | Mock servers, performance | `02-load-balancing` |
| **Node.js** | `18+` | Mock servers alternativos | `02-load-balancing` |
| **Shell Script** | Bash 4+ | Scripts de automação/demo | Todos os projetos |

## 🐳 Containers e Imagens

### Kong Ecosystem

```yaml
# Imagens oficiais utilizadas
services:
  kong:
    image: kong:3.4-alpine
    # Lightweight, produção-ready
    
  kong-database:
    image: postgres:13-alpine  
    # Quando necessário (modo database)
```

### Mock Services

```yaml
# Go Mock Server (performance)
go-mock:
  build: ./go-mock-server
  # Custom Dockerfile com multi-stage build

# Node.js Mock Server (comparação)  
node-mock:
  build: ./node-mock-server
  # Express.js básico para benchmarking
```

### Monitoring Stack

```yaml
# Observabilidade completa
prometheus:
  image: prom/prometheus:v2.47.0
  
grafana:
  image: grafana/grafana:10.1.0
```

## 📦 Dependências por Projeto

### 01-basic-proxy
**Dependências**:
- Kong Gateway (proxy core)
- JSONPlaceholder API (upstream mock)

**Portas utilizadas**:
- `8000` - Kong Proxy
- `8001` - Kong Admin API
- `8443` - Kong Proxy SSL
- `8444` - Kong Admin SSL

### 02-load-balancing
**Dependências**:
- Kong Gateway
- Go runtime (mock server)
- Node.js runtime (mock server alternativo)

**Bibliotecas Go**:
```go
// go.mod
module mock-server

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/prometheus/client_golang v1.17.0
)
```

**Bibliotecas Node.js**:
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "morgan": "^1.10.0"
  }
}
```

### 03-authentication
**Dependências**:
- Kong Gateway
- Kong JWT Plugin
- Kong Key Auth Plugin
- OpenSSL (geração de chaves JWT)

**Plugins Kong**:
```yaml
plugins:
- name: jwt
  config:
    secret_is_base64: false
    
- name: key-auth
  config:
    key_names: ["apikey"]
```

### 04-rate-limiting
**Dependências**:
- Kong Gateway  
- Kong Rate Limiting Plugin
- Redis (opcional, para políticas avançadas)

**Configurações**:
```yaml
plugins:
- name: rate-limiting
  config:
    minute: 100
    hour: 1000
    policy: local  # ou 'redis'
```

### 05-transformations
**Dependências**:
- Kong Gateway
- Kong Request Transform Plugin
- Kong Response Transform Plugin

### 06-custom-plugin
**Dependências**:
- Kong Gateway
- Lua 5.1 (LuaJIT)
- Kong PDK (Plugin Development Kit)

**Estrutura Plugin**:
```lua
-- Dependências Lua implícitas
local BasePlugin = require "kong.plugins.base_plugin"
local json = require "cjson"
```

### 07-metrics
**Dependências**:
- Kong Gateway + Prometheus Plugin
- Prometheus Server
- Grafana
- cURL/wrk (load testing)

## 🔧 Ferramentas de Desenvolvimento

### Obrigatórias

| Ferramenta | Versão | Propósito | Instalação |
|------------|--------|-----------|------------|
| **Docker** | `24.0+` | Runtime de containers | [Get Docker](https://docs.docker.com/get-docker/) |
| **Docker Compose** | `2.20+` | Orquestração | Incluído no Docker Desktop |
| **Make** | `4.0+` | Automação de tarefas | `apt install make` / `brew install make` |
| **curl** | `7.0+` | Testes HTTP básicos | Pré-instalado na maioria dos SOs |

### Recomendadas

| Ferramenta | Versão | Propósito | Instalação |
|------------|--------|-----------|------------|
| **Bruno** | `1.0+` | Cliente API estruturado | [usebruno.com](https://www.usebruno.com/) |
| **jq** | `1.6+` | Processamento JSON | `apt install jq` / `brew install jq` |
| **httpie** | `3.0+` | HTTP client amigável | `pip install httpie` |
| **wrk** | `4.2+` | Load testing | `apt install wrk` / `brew install wrk` |

### Opcionais (Desenvolvimento)

| Ferramenta | Propósito | Instalação |
|------------|-----------|------------|
| **markdownlint** | Linting de documentação | `npm i -g markdownlint-cli` |
| **shellcheck** | Linting de shell scripts | `apt install shellcheck` |
| **hadolint** | Linting de Dockerfiles | `brew install hadolint` |
| **Bruno CLI** | Automação de testes API | `npm i -g @usebruno/cli` |

## 🌐 APIs e Serviços Externos

### Mock APIs Utilizadas
- **JSONPlaceholder**: `https://jsonplaceholder.typicode.com`
  - Propósito: Upstream de exemplo para testes
  - Endpoints: `/users`, `/posts`, `/comments`
  - Gratuito, sem autenticação necessária

### Imagens Docker Registry
- **Docker Hub**: Repositório principal de imagens
- **Kong Official**: `kong:latest`, `kong:3.4-alpine`
- **Prometheus**: `prom/prometheus:latest`
- **Grafana**: `grafana/grafana:latest`

## 📊 Configurações de Rede

### Portas Padrão por Projeto

```
┌─────────────────┬─────────┬───────────────────┐
│     Serviço     │  Porta  │    Propósito      │
├─────────────────┼─────────┼───────────────────┤
│ Kong Proxy      │  8000   │ Tráfego principal │
│ Kong Admin      │  8001   │ Configuração      │
│ Kong Proxy SSL  │  8443   │ HTTPS             │
│ Kong Admin SSL  │  8444   │ HTTPS Admin       │
│ Prometheus      │  9090   │ Métricas          │
│ Grafana         │  3000   │ Dashboards        │
│ Go Mock         │  3001   │ Upstream teste    │
│ Node Mock       │  3002   │ Upstream teste    │
└─────────────────┴─────────┴───────────────────┘
```

### Networks Docker
```yaml
# Rede padrão por projeto
networks:
  kong-net:
    driver: bridge
    
# Permite comunicação inter-containers
# Isolamento por projeto (docker-compose up)
```

## 🔒 Segurança e Credenciais

### Configurações de Desenvolvimento
```yaml
# Variáveis padrão (development only)
KONG_ADMIN_LISTEN: 0.0.0.0:8001
KONG_PROXY_LISTEN: 0.0.0.0:8000

# Grafana (dev credentials)
GF_SECURITY_ADMIN_USER: admin
GF_SECURITY_ADMIN_PASSWORD: admin
```

⚠️ **IMPORTANTE**: Estas são configurações de desenvolvimento/demo. **NUNCA** usar em produção.

### JWT Secrets (Demo)
```bash
# Chaves geradas dinamicamente por projeto
openssl genpkey -algorithm RS256 -out private.pem
openssl rsa -pubout -in private.pem -out public.pem
```

## 🔄 Versionamento e Updates

### Política de Versionamento
- **Kong Gateway**: Sempre usar versão LTS mais recente
- **Prometheus/Grafana**: Latest stable
- **Base Images**: Alpine quando disponível (menor footprint)
- **Language Runtimes**: LTS versions

### Update Schedule
```bash
# Verificar updates mensalmente
make check-updates

# Update seguro (pull + test)
make update-images
make test-all
```

## 📈 Performance e Resources

### Resource Limits (Recomendado)
```yaml
# docker-compose.yml example
services:
  kong:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### Benchmarks Esperados
- **Kong Proxy**: 5000+ req/s (single core)
- **Go Mock Server**: 25000+ req/s
- **Node Mock Server**: 8000+ req/s
- **Memory Usage**: < 1GB total per projeto

## 🛠️ Troubleshooting

### Dependências Comuns
```bash
# Verificar todas as dependências
make check-deps

# Problemas comuns:
# 1. Docker não rodando
systemctl start docker

# 2. Portas ocupadas  
lsof -i :8000
kill -9 <PID>

# 3. Images outdated
docker-compose pull
```

### Logs e Debug
```bash
# Logs específicos por serviço
docker-compose logs kong
docker-compose logs prometheus
docker-compose logs grafana

# Debug de conectividade
docker exec <container> ping <target>
```

---

## 📚 Referências Técnicas

- [Kong Gateway Documentation](https://docs.konghq.com/gateway/)
- [Docker Compose Specification](https://compose-spec.io/)
- [Prometheus Configuration](https://prometheus.io/docs/prometheus/latest/configuration/)
- [Grafana Data Sources](https://grafana.com/docs/grafana/latest/datasources/)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)

**🎯 Objetivo**: Manter um stack de tecnologias moderna, estável e educacionalmente eficaz!