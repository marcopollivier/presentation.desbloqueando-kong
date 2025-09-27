# Estratégia de Testes - Kong Gateway Workshop

## 🎯 Visão Geral

Este documento define a **estratégia de testes** para o Kong Gateway Workshop, cobrindo desde validações básicas de configuração até testes de carga e integração completa.

## 🧪 Pirâmide de Testes

```
┌─────────────────────────────────────┐
│           E2E Tests                 │ ← Bruno Collections, Demo Scripts
│        (Comportamento)              │
├─────────────────────────────────────┤
│         Integration Tests           │ ← Docker Compose, Health Checks
│        (Componentes)                │
├─────────────────────────────────────┤
│          Unit Tests                 │ ← Config Validation, Plugin Logic
│         (Isolados)                  │
└─────────────────────────────────────┘
```

## 📊 Níveis de Teste

### 1. Unit Tests (Testes Unitários)
**Escopo**: Configurações, plugins Lua, scripts individuais

```bash
# Validação de configuração Kong
make test-kong-config

# Validação de Docker Compose
make test-docker-config

# Testes de plugins Lua (quando aplicável)
make test-plugins
```

**Ferramentas**:
- `docker-compose config` - Validação de sintaxe
- `kong config -c kong.yml` - Validação Kong
- `busted` - Framework Lua testing (plugins customizados)

### 2. Integration Tests (Testes de Integração)
**Escopo**: Containers, comunicação entre serviços, health checks

```bash
# Teste de integração por projeto
make test-project PROJECT=01-basic-proxy

# Health checks automáticos
make test-health-all

# Conectividade entre serviços
make test-connectivity
```

**Cenários Testados**:
- ✅ Containers sobem corretamente
- ✅ Kong conecta com upstreams
- ✅ Plugins funcionam conforme esperado
- ✅ Métricas são coletadas (projeto 07)
- ✅ Load balancing distribui corretamente

### 3. E2E Tests (Testes End-to-End)
**Escopo**: Workflows completos, cenários de usuário, demos

```bash
# Bruno API collections
make test-bruno

# Demo automatizado completo
make test-demo-complete

# Testes de carga
make test-load
```

**Cenários Cobertos**:
- 🔄 Proxy básico funcionando
- 🔄 Autenticação JWT/Key Auth
- 🔄 Rate limiting ativo
- 🔄 Transformações aplicadas
- 🔄 Métricas sendo coletadas
- 🔄 Load balancing em ação

## 🛠️ Ferramentas de Teste

### Bruno API Client
**Propósito**: Testes de API estruturados e reproduzíveis

```bash
# Instalar Bruno CLI
npm install -g @usebruno/cli

# Executar coleção completa
cd _bruno/kong
bruno run

# Executar pasta específica
bruno run --folder "01 - Base requests"
```

**Estrutura das Collections**:
```
_bruno/kong/
├── 01 - Base requests/     # Smoke tests básicos
├── 02 - Load balancer/     # Testes de distribuição
├── 03 - auth/              # Testes de autenticação
├── 04 - rate limit/        # Testes de throttling
├── 05 - transformation/    # Testes de transformação
└── 06 - lua plugin/        # Plugin customizado
```

### Scripts de Demo
**Propósito**: Validação automatizada de cenários completos

```bash
# Demo individual por projeto
cd 01-basic-proxy
./demo.sh

# Load testing (projeto 07)
cd 07-metrics  
./load-test.sh
```

### Health Checks
**Propósito**: Monitoramento contínuo da saúde dos serviços

```bash
# Verificar status de todos os serviços
make status

# Health check específico
curl -f http://localhost:8001/status || exit 1
```

## 📋 Matriz de Testes por Projeto

### 01-basic-proxy
- ✅ **Unit**: Config Kong válida
- ✅ **Integration**: Container Kong + upstream mock
- ✅ **E2E**: Requisição via proxy retorna 200

```bash
# Sequência de testes
cd 01-basic-proxy
docker-compose up -d
curl -f http://localhost:8000/api/users
docker-compose down -v
```

### 02-load-balancing
- ✅ **Unit**: Upstream config com múltiplos targets
- ✅ **Integration**: Go + Node.js containers respondem
- ✅ **E2E**: Round-robin distribution confirmada

```bash
# Teste de distribuição
cd 02-load-balancing
docker-compose up -d
./test-load-balancing.sh  # Verifica distribuição
docker-compose down -v
```

### 03-authentication
- ✅ **Unit**: JWT/Key auth plugin config
- ✅ **Integration**: Auth plugin ativo no Kong
- ✅ **E2E**: Requisições rejeitadas sem token

```bash
# Teste de autenticação
cd 03-authentication
docker-compose up -d
# Sem token = 401
curl http://localhost:8000/api/users
# Com token = 200  
curl -H "Authorization: Bearer $(./generate-jwt.sh)" http://localhost:8000/api/users
```

### 04-rate-limiting
- ✅ **Unit**: Rate limit plugin configuração
- ✅ **Integration**: Redis conectado (se usado)
- ✅ **E2E**: Rate limit aplicado após X requests

### 05-transformations
- ✅ **Unit**: Transform plugin config válida
- ✅ **Integration**: Transformação aplicada corretamente
- ✅ **E2E**: Request/response modificados conforme esperado

### 06-custom-plugin
- ✅ **Unit**: Plugin Lua sintaxe válida
- ✅ **Integration**: Plugin carregado no Kong
- ✅ **E2E**: Lógica customizada executando

### 07-metrics
- ✅ **Unit**: Prometheus config válida
- ✅ **Integration**: Kong → Prometheus → Grafana
- ✅ **E2E**: Métricas coletadas e dashboards funcionais

## 🚀 Automação de Testes

### CI/CD Pipeline (GitHub Actions exemplo)

```yaml
name: Kong Workshop Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Dependencies
      run: make check-deps
      
    - name: Lint Configurations
      run: make lint
      
    - name: Unit Tests
      run: make test-configs
      
    - name: Integration Tests  
      run: make test-all
      
    - name: E2E Tests
      run: make test-bruno
```

### Makefile Targets
```bash
# Teste completo automatizado
make test              # Roda todos os testes

# Testes específicos por nível
make test-unit         # Apenas unit tests
make test-integration  # Apenas integration tests  
make test-e2e          # Apenas E2E tests

# Testes por projeto
make test-project PROJECT=01-basic-proxy
```

## 🎭 Cenários de Teste

### Cenários Positivos (Happy Path)
- ✅ Todos os containers sobem corretamente
- ✅ Requisições passam pelos plugins
- ✅ Load balancing distribui uniformemente
- ✅ Métricas são coletadas sem erros
- ✅ Autenticação aceita tokens válidos

### Cenários Negativos (Error Handling)
- ❌ Upstream indisponível → Kong retorna 503
- ❌ Token inválido → Kong retorna 401  
- ❌ Rate limit excedido → Kong retorna 429
- ❌ Configuração inválida → Container não sobe

### Cenários de Performance
- ⚡ Kong handle 1000 req/s sem erro
- ⚡ Latência p95 < 100ms
- ⚡ Memory usage < 512MB por container
- ⚡ CPU usage < 80% durante load test

## 📊 Métricas de Qualidade

### Cobertura de Testes
- **Config Files**: 100% (todos validados)
- **API Endpoints**: 90%+ (Bruno collections)
- **Error Scenarios**: 80%+ (cenários negativos)
- **Performance**: Benchmarks definidos

### SLIs (Service Level Indicators)
- **Availability**: 99.9%+ durante testes
- **Latency**: p95 < 100ms, p99 < 500ms
- **Error Rate**: < 1% em cenários normais
- **Throughput**: > 500 req/s por projeto

## 🔧 Setup de Ambiente de Teste

### Pré-requisitos
```bash
# Verificar dependências
make check-deps

# Setup ambiente de teste
make test-setup

# Instalar ferramentas opcionais
npm install -g @usebruno/cli
npm install -g markdownlint-cli
```

### Variáveis de Ambiente
```bash
# Configurações de teste
export KONG_TEST_TIMEOUT=30
export LOAD_TEST_DURATION=60s
export LOAD_TEST_RATE=100

# Para CI/CD
export CI=true
export SKIP_INTERACTIVE_TESTS=true
```

## 🐛 Debugging de Testes

### Logs e Debugging
```bash
# Logs detalhados durante teste
VERBOSE=1 make test-project PROJECT=01-basic-proxy

# Debug de container específico
docker logs kong-basic-proxy-1 --tail 50

# Debug de conectividade
docker exec kong-basic-proxy-1 ping upstream-mock
```

### Troubleshooting Comum
- **Container não sobe**: Verificar ports disponíveis
- **503 Service Unavailable**: Upstream não está respondendo
- **Plugin não carrega**: Verificar sintaxe Lua
- **Métricas não aparecem**: Verificar configuração Prometheus

---

## 📚 Referências

- [Kong Testing Guide](https://docs.konghq.com/gateway/latest/plugin-development/tests/)
- [Bruno Documentation](https://docs.usebruno.com/)
- [Docker Compose Testing](https://docs.docker.com/compose/test-deploy/)
- [Prometheus Testing](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/)

**🎯 Objetivo**: Garantir que cada projeto funcione perfeitamente para uma experiência educacional sem problemas!