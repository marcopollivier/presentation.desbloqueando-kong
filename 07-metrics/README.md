# Kong Gateway - Metrics & Load Balancing Demo 🚀

## Visão Geral

Demo completo do Kong Gateway com **Prometheus**, **Grafana** e **Load Balancing** entre dois mock services locais. Demonstra métricas em tempo real e distribuição de carga entre serviços Go e Node.js.

## Stack Completa

```
Client → Kong Gateway ⟷ Go Mock API (3001)
           ↓ (metrics)  ⟷ Node Mock API (3002)
        Prometheus → Grafana Dashboard
```

## 🚀 Quick Start

### 1. Subir os Mock Services

```bash
cd ../00-mock-services
make setup && make up
cd ../07-metrics
```

### 2. Subir a Stack de Métricas

```bash
docker-compose up -d
# ou: podman-compose up -d
```

### 3. Executar Teste de Carga

```bash
./load-test.sh
```

### 3. Acessar Dashboards

- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Kong Admin**: http://localhost:8001
- **Kong Proxy**: http://localhost:8000

## 📊 Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `presentation-demo.sh` | 🎬 **Demo interativo completo** |
| `simple-load-test.sh` | 🚀 Gera 600 requests rapidamente |
| `verify-setup.sh` | 🧪 Verifica se tudo está funcionando |
| `fix-dashboard.sh` | 🔧 Recarrega dashboard se necessário |

## 🎯 Para Apresentações

1. Execute: `./presentation-demo.sh`
2. Escolha opção **1** (gerar tráfego)
3. Abra Grafana: http://localhost:3000
4. Login: `admin` / `admin123`
5. Dashboard: **"Kong Gateway Metrics"**
6. Mostre métricas em tempo real!

## 📈 Métricas Disponíveis

- **Total Requests** - Contador geral
- **Request Rate** - Requests por segundo
- **Response Time** - Latência P50/P95/P99
- **Error Rate** - Taxa de erro por código
- **Throughput** - Volume de dados

## 🔧 Configuração

### Mock Services (00-mock-services/)
- **Go Mock API**: Porta 3001 (alta performance)
- **Node Mock API**: Porta 3002 (rico ecossistema)
- Network externa para comunicação com Kong
- Health checks configurados

### Kong (kong.yml)
- Upstream com round-robin entre os dois services
- Plugin Prometheus habilitado globalmente
- Métricas expostas na porta 8100
- Health checks ativos para os targets

### Prometheus (prometheus/prometheus.yml)
- Scraping Kong a cada 5 segundos
- Target: `kong:8100/metrics`

### Grafana
- Dashboard auto-provisionado
- Datasource Prometheus configurado
- Painéis pré-configurados para load balancing

## 🌐 Endpoints de Teste

```bash
# GET requests (200) - balanceados entre Go e Node
curl http://localhost:8000/api/users
curl http://localhost:8000/api/users/1
curl http://localhost:8000/api/health

# POST requests (201)
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

# 404 errors
curl http://localhost:8000/api/nonexistent
curl http://localhost:8000/api/users/99999
```

## 🐛 Troubleshooting

### Dashboard mostra "No Data"

```bash
./verify-setup.sh  # Diagnóstico completo
./simple-load-test.sh  # Gerar tráfego
```

### Recarregar Dashboard

```bash
./fix-dashboard.sh
```

### Ver Métricas Direto

```bash
curl http://localhost:8100/metrics | grep kong_http
```

### ⚠️ Warning "Server time is out of sync" no Prometheus

**Este é um problema conhecido do Podman no macOS:**

- ✅ **As métricas funcionam PERFEITAMENTE**
- ✅ **Queries temporais (increase, rate) estão OK** 
- ✅ **Dashboards mostram dados corretos**
- ⚠️ **É apenas um aviso cosmético**

**Para apresentação:**
- Ignore o warning amarelo no Prometheus
- Foque nos dashboards do Grafana
- As métricas são precisas e funcionais
- Explique que é limitação do ambiente de dev

**Solução em produção:**
- Use Docker ao invés de Podman
- Configure NTP nos containers
- Use Kubernetes para gerenciamento

```bash
./time-warning-info.sh  # Informações detalhadas
```

## 📁 Estrutura

```
01-basic-proxy/
├── docker-compose.yml           # Stack completa
├── kong.yml                     # Config Kong + Prometheus
├── presentation-demo.sh         # 🎬 Demo principal  
├── simple-load-test.sh          # 🚀 Gerador de tráfego
├── verify-setup.sh              # 🧪 Verificação
├── fix-dashboard.sh             # 🔧 Fix dashboard
├── prometheus/
│   └── prometheus.yml           # Config Prometheus
└── grafana/
    ├── provisioning/            # Auto-provisioning
    └── dashboards/
        └── kong-dashboard.json  # Dashboard Kong
```

## 🎯 Portas

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| Kong Proxy | 8000 | API Gateway |
| Kong Admin | 8001 | Administração |
| Kong Metrics | 8100 | Métricas Prometheus |
| Prometheus | 9090 | Time Series DB |
| Grafana | 3000 | Dashboards |

## ✅ Demo Checklist

- [ ] `podman compose up -d`
- [ ] `./presentation-demo.sh`
- [ ] Gerar tráfego (opção 1)
- [ ] Abrir Grafana (opção 3)
- [ ] Login admin/admin123
- [ ] Dashboard "Kong Gateway Metrics"
- [ ] Mostrar métricas em tempo real!

---

🎯 **Ready for presentation!** 
Use `./presentation-demo.sh` para começar.
- **Configuração Declarativa**: kong.yml vs Admin API
- **Plugin Prometheus**: Coleta de métricas automática
- **Observabilidade**: Monitoramento e visualização de métricas

## 🚀 Como Executar

### 1. Subir o ambiente completo

```bash
docker-compose up -d
```

Isso irá iniciar:

- **Kong Gateway** (portas 8000, 8001, 8100)
- **Prometheus** (porta 9090)
- **Grafana** (porta 3000) com dashboard já configurado

### 2. Acessar as interfaces

- **Grafana**: <http://localhost:3000>
  - Usuário: `admin`
  - Senha: `admin123`
  - Dashboard: "Kong Gateway Metrics" (já provisionado automaticamente)

- **Prometheus**: <http://localhost:9090>
  - Explore métricas do Kong
  - Query examples: `kong_http_requests_total`, `kong_request_latency_ms`

- **Kong Admin API**: <http://localhost:8001>

### 3. Gerar tráfego para visualizar métricas

```bash
# Use o script interativo para gerar diferentes tipos de tráfego
./load-test.sh
```

**Opções disponíveis:**

1. Tráfego leve (demonstração básica)
2. Tráfego moderado (cenário real)
3. Tráfego intenso (teste de carga)
4. Burst de requisições (picos de tráfego)
5. Tráfego contínuo (apresentação em tempo real)

### 4. Testar manualmente

```bash
# Teste básico - deve retornar dados do JSONPlaceholder
curl -i http://localhost:8000/api/posts

# Teste com parâmetro
curl -i http://localhost:8000/api/posts/1

# Verificar status do Kong
curl -i http://localhost:8001/status

# Ver métricas do Prometheus
curl -s http://localhost:8100/metrics | grep kong_
```

## 📊 Métricas Disponíveis

O dashboard do Grafana mostra:

### Métricas de Alto Nível

- **Total de Requests**: Contador total de requisições
- **Taxa de Requests**: Requisições por segundo
- **Tempo de Resposta Médio**: Latência média
- **Taxa de Erro**: Porcentagem de erros 5xx

### Gráficos Detalhados

- **Request Rate Over Time**: Evolução do tráfego
- **Response Time Percentiles**: P50, P95, P99
- **HTTP Status Codes**: Distribuição de códigos de resposta
- **Kong Status**: Status de conectividade

## 🎭 Script para Apresentação

Use o script de demonstração guiada:

```bash
./demo-presentation.sh
```

Ou faça manualmente:

```bash
# 1. Mostrar ambiente limpo
docker-compose up -d && sleep 30

# 2. Abrir Grafana e mostrar dashboard zerado
open http://localhost:3000

# 3. Gerar tráfego e mostrar métricas aparecendo
./load-test.sh  # Opção 1 ou 4

# 4. Explorar Prometheus
open http://localhost:9090
```

## 📚 Pontos de Discussão para Palestra

### 1. **Por que Observabilidade é Crítica?**

- Identificação proativa de problemas
- Capacidade de planejamento (capacity planning)
- SLO/SLA monitoring
- Troubleshooting em produção

### 2. **Kong + Prometheus + Grafana**

- Plugin nativo do Kong para Prometheus
- Métricas out-of-the-box
- Dashboards customizáveis
- Alerting capabilities

### 3. **Métricas que Importam**

- **Golden Signals**: Latency, Traffic, Errors, Saturation
- **Business Metrics**: Requests por endpoint, por consumidor
- **Infrastructure Metrics**: CPU, memória, conexões

## 🧹 Limpeza

```bash
docker-compose down -v
```

## 📁 Estrutura Final

```
01-basic-proxy/
├── docker-compose.yml          # Serviços: Kong + Prometheus + Grafana
├── kong.yml                    # Config Kong + Plugin Prometheus
├── load-test.sh               # Script para gerar tráfego
├── demo-presentation.sh       # Demo guiada
├── prometheus/
│   └── prometheus.yml         # Config do Prometheus
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   │   └── prometheus.yml # Auto-config datasource
    │   └── dashboards/
    │       └── kong.yml       # Auto-provision dashboards
    └── dashboards/
        └── kong-dashboard.json # Dashboard customizado
```
