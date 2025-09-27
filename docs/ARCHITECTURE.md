# Arquitetura - Kong Gateway Workshop

## 🏗️ Visão Geral da Arquitetura

Este projeto segue uma **arquitetura educacional progressiva** que demonstra padrões de API Gateway do mundo real através de exemplos práticos evolutivos.

## 🎯 Princípios Arquiteturais

### Clean Architecture


- **Separação de responsabilidades** por layers
- **Independência de frameworks** (Kong como infraestrutura)
- **Testabilidade** através de abstrações
- **Inversão de dependências** nos plugins customizados


### Vertical Slices

- Cada projeto (01-07) é uma **fatia vertical completa**
- **Feature completa** por diretório (config + demo + testes)
- **Mínima interdependência** entre projetos
- **Deploy independente** via Docker Compose


### Hexagonal Architecture (Ports & Adapters)

```
┌─────────────────────────────────────────┐
│              Kong Gateway               │
│  ┌─────────────────────────────────────┐ │
│  │           Core Business             │ │
│  │      (Routing, Policies)            │ │
│  │                                     │ │
│  └─────────────────────────────────────┘ │
│    ▲                             ▲      │
│    │ (Ports)           (Ports)   │      │
│    │                             │      │
│    ▼                             ▼      │
│ ┌──────┐                   ┌──────────┐ │
│ │Plugin│                   │Upstream  │ │
│ │Adaptr│                   │Adapter   │ │
│ └──────┘                   └──────────┘ │
└─────────────────────────────────────────┘
```


## 📁 Estrutura Arquitetural

### Organização por Domínio

```
desbloqueando-kong/
├── 01-basic-proxy/         # 🎯 Domínio: Proxy Básico
│   ├── kong.yml           # → Configuração (Infrastructure)
│   ├── docker-compose.yml # → Orquestração (Infrastructure)
│   └── README.md          # → Documentação (Application)
│
├── 02-load-balancing/     # 🎯 Domínio: Distribuição de Carga
│   ├── kong.yml           # → Políticas de LB (Core Business)
│   ├── go-mock-server/    # → Adapter (Port - HTTP)
│   ├── node-mock-server/  # → Adapter (Port - HTTP)
│   └── test-*.sh          # → Testes de Integração
│
├── 06-custom-plugin/      # 🎯 Domínio: Extensibilidade
│   ├── kong/plugins/      # → Core Business Logic
│   │   └── request-validator/
│   │       ├── handler.lua    # → Business Rules
│   │       └── schema.lua     # → Domain Model
│   └── Dockerfile         # → Infrastructure
│
└── 07-metrics/            # 🎯 Domínio: Observabilidade
    ├── prometheus/        # → Monitoring Adapter
    ├── grafana/           # → Visualization Adapter
    └── load-test.sh       # → Testing Port
```


## 🔄 Padrões de Integração

### Event-Driven Architecture

```
┌─────────────┐    metrics    ┌─────────────┐
│    Kong     │──────────────▶│ Prometheus  │
│   Gateway   │               │             │
└─────────────┘               └─────────────┘
       │                              │
       │ proxy                        │ scrape
       ▼                              ▼
┌─────────────┐                ┌─────────────┐
│  Upstream   │                │   Grafana   │

│  Services   │                │ Dashboards  │
└─────────────┘                └─────────────┘
```

### Plugin Architecture (Strategy Pattern)

```lua
-- handler.lua (Strategy Implementation)
local BasePlugin = require "kong.plugins.base_plugin"
local CustomPlugin = BasePlugin:extend()

function CustomPlugin:access(conf)
  CustomPlugin.super.access(self)
  -- Business Logic Here (Domain Layer)
end


return CustomPlugin
```

## 🧩 Camadas Arquiteturais

### 1. Infrastructure Layer


- **Docker Compose**: Orquestração de containers
- **Kong Configuration**: `kong.yml` (declarativo)
- **Network**: Bridges, service discovery
- **Storage**: Volumes para logs/métricas


### 2. Application Layer  

- **Kong Core**: Proxy engine, plugin system
- **Demo Scripts**: Automação de cenários
- **Health Checks**: Validação de serviços
- **Load Tests**: Validação de performance


### 3. Domain Layer

- **Routing Rules**: Lógica de roteamento
- **Security Policies**: Autenticação/autorização  
- **Rate Limiting**: Políticas de throttling
- **Transform Rules**: Manipulação de dados


### 4. Interface Layer

- **HTTP APIs**: Endpoints expostos
- **Admin API**: Gerenciamento Kong
- **Metrics Endpoints**: Observabilidade
- **Bruno Collections**: Interface de teste

## 🔧 Padrões de Configuração

### Declarative Configuration (Infrastructure as Code)

```yaml
# kong.yml - Single Source of Truth
_format_version: "3.0"

services:
- name: api-service

  url: http://upstream:3000
  routes:
  - name: api-route
    paths: ["/api"]
  plugins:
  - name: rate-limiting
    config:
      minute: 100
```

### Environment-Specific Overrides

```yaml
# kong.development.yml
services:

- name: api-service
  url: http://localhost:3000  # Local override
  
# kong.production.yml  
services:
- name: api-service
  url: http://api.internal:3000  # Production override
```

## 📊 Padrões de Observabilidade

### Monitoring Architecture


```
Application Metrics (Business) 
          ↓
    Kong Metrics (Infrastructure)
          ↓  
    Prometheus (Storage)
          ↓
     Grafana (Visualization)

          ↓
    Alerts (Notification)
```

### SRE Golden Signals

- **Latency**: Response time percentiles
- **Traffic**: Request rate per service
- **Errors**: Error rate by status code
- **Saturation**: Resource utilization

## 🧪 Testing Architecture

### Test Pyramid

```

┌─────────────────┐
│   E2E Tests     │ ← Bruno Collections
│   (Integration) │
├─────────────────┤
│  Service Tests  │ ← Load tests, Health checks
│  (Component)    │  
├─────────────────┤
│   Unit Tests    │ ← Plugin logic, Config validation
│   (Isolated)    │
└─────────────────┘

```

## 🔒 Security Architecture

### Defense in Depth

1. **Network**: Kong proxy layer
2. **Authentication**: Key/JWT validation  
3. **Authorization**: RBAC plugins

4. **Rate Limiting**: DDoS protection
5. **Validation**: Request/response schemas
6. **Monitoring**: Anomaly detection

## 🚀 Deployment Patterns

### Blue-Green Deployment

```bash
# Deploy new version alongside current
make deploy-blue   # New version
make test-blue     # Validate  
make switch-blue   # Route traffic (atomic)
make cleanup-green # Remove old version
```

### Canary Deployment

```yaml
# Progressive traffic shifting

upstreams:
- name: api-upstream
  targets:
  - target: api-v1:3000
    weight: 90  # 90% traffic
  - target: api-v2:3000  
    weight: 10  # 10% traffic (canary)
```

---

## 📚 Referências Arquiteturais

- **Clean Architecture**: Uncle Bob's principles
- **Hexagonal Architecture**: Ports & Adapters pattern
- **Vertical Slice Architecture**: Feature-driven organization
- **API Gateway Pattern**: Microservices integration
- **Event-Driven Architecture**: Loose coupling via events
