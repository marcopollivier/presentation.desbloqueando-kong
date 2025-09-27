# 🔄 Load Balancing com Kong Gateway

## 🎯 Objetivos
- Configurar Upstream com targets em **Go e Node.js**
- **Comparar performance** entre Go e Node.js em tempo real
- Implementar algoritmos de load balancing
- Configurar health checks ativos e passivos
- Demonstrar failover automático
- **Benchmarking** comparativo entre as linguagens

## 🏗️ Arquitetura Go vs Node.js

```
                             Kong Gateway
                         ┌─────────────────┐
                         │   Load Balancer │
                         │   (Round Robin) │
                         └─────────┬───────┘
                                   │
                       ┌───────────┼───────────┐
                       │           │           │
             ┌─────────▼─────────┐ │ ┌─────────▼─────────┐
             │   🐹 Go API-1     │ │ │🟨 Node.js API-2   │
             │   (Goroutines)    │ │ │  (Event Loop)     │
             │   ~25k req/s      │ │ │   ~8k req/s       │
             │   Port: 3001      │ │ │   Port: 3002      │
             └───────────────────┘ │ └───────────────────┘
                                   │
                          Performance Battle!
```

## 🔬 Comparativo Go vs Node.js

| Aspecto | 🐹 **Go** | 🟨 **Node.js** |
|---------|----------|---------------|
| **Performance** | ~25k req/s | ~8k req/s |
| **Concorrência** | Goroutines | Event Loop |
| **Memory Safety** | GC | GC |
| **Compilação** | Rápida | Interpretado |
| **Curva Aprendizado** | Média | Baixa |
| **Ecosistema** | Crescendo | Massivo |
## 📋 Conceitos Apresentados

- **Upstream**: Agrupamento de targets (backends) em 3 linguagens
- **Load Balancing**: Round-robin, Weighted, Hash-based
- **Health Checks**: Ativos (polling) e Passivos (por requisição)
- **Failover**: Recuperação automática de targets
- **Performance Comparison**: Benchmarks em tempo real

## 🚀 Como Executar

### 1. Subir o ambiente (Kong + Go + Node.js)

```bash
docker compose up -d --build
```
```

## 📋 Conceitos Apresentados
- **Upstream**: Agrupamento de targets (backends)
- **Target**: Instância individual de um serviço Go
- **Load Balancing Algorithms**: round-robin, least-connections, hash
- **Health Checks**: Active vs Passive monitoring  
- **Circuit Breaker**: Proteção contra targets com falha
- **Performance**: Go vs Node.js mock servers

## 🚀 Como Executar

### 1. Subir o ambiente (Kong + 3 Go mock APIs)
```bash
docker-compose up -d --build
```

### 2. Verificar targets disponíveis
```bash
# Listar upstreams
curl -s http://localhost:8001/upstreams | jq

# Ver targets do upstream
curl -s http://localhost:8001/upstreams/api-upstream/targets | jq

# Ver health status
curl -s http://localhost:8001/upstreams/api-upstream/health | jq
```

### 3. Testar load balancing
```bash
# Execute múltiplas vezes para ver round-robin
for i in {1..9}; do
  echo "Request $i:"
  curl -s http://localhost:8000/api/posts/1 | jq '.server_info.server // .id'
  sleep 0.5
done
```

### 4. Simular falha de um target
```bash
# Parar um dos Go mock servers
docker-compose stop go-mock-api-2

# Aguardar health check detectar (30s)
sleep 35

# Verificar health status
curl -s http://localhost:8001/upstreams/api-upstream/health | jq

# Testar requests - deve funcionar apenas com targets saudáveis
for i in {1..6}; do
  echo "Request $i (after failure):"
  curl -s http://localhost:8000/api/posts/1 | jq '.server_info.server // .id'
  sleep 0.5
done
```

### 5. Recuperar o target
```bash
# Restart do target
docker-compose start go-mock-api-2

# Aguardar recuperação
sleep 35

# Verificar health novamente
curl -s http://localhost:8001/upstreams/api-upstream/health | jq
```

### 6. Testar diferentes algoritmos
```bash
# Adicionar weight diferente para um target
curl -X POST http://localhost:8001/upstreams/api-upstream/targets \
  -d "target=go-mock-api-1:3001" \
  -d "weight=200"

# Testar distribuição com weight
for i in {1..10}; do
  curl -s http://localhost:8000/api/posts/1 | jq '.server_info.server // .id'
done
```

### 7. Comparar performance Go
```bash
# Testar endpoint de performance dos Go servers
curl -s http://localhost:3001/performance | jq
curl -s http://localhost:3002/performance | jq
curl -s http://localhost:3003/performance | jq

# Benchmark através do Kong
time for i in {1..100}; do
  curl -s http://localhost:8000/api/performance > /dev/null
done
```

## 📚 Pontos de Discussão

1. **Algoritmos de Load Balancing**
   - round-robin: Distribui igualmente
   - least-connections: Menos conexões ativas
   - hash: Baseado em hash (sticky sessions)
   - weighted-round-robin: Com pesos diferentes

2. **Health Checks**
   - **Active**: Kong faz requests periódicos
   - **Passive**: Baseado em responses dos requests reais
   - Thresholds configuráveis

3. **Circuit Breaker Pattern**
   - Protege contra cascading failures
   - Remove automaticamente targets com falha
   - Recuperação automática quando target volta

4. **Configurações Avançadas**
   - Connection pooling
   - Retry policies
   - Timeout configurations

## ⚡ Por que Três Linguagens?

Este projeto demonstra **comparação prática de performance** em um cenário real de load balancing:

### � **Go - O Equilibrado**

- **Concorrência nativa**: Goroutines são muito mais leves que threads  
- **Compilado**: Binário nativo elimina overhead do interpretador
- **Baixa latência**: Ideal para cenários onde cada milissegundo conta
- **Performance**: ~25,000 req/s - excelente para APIs de produção

### 🟨 **Node.js - O Ágil**

- **Ecosistema massivo**: NPM com 2M+ pacotes, desenvolvimento rápido
- **Event-driven**: Single-thread eficiente para I/O intensivo
- **JavaScript isomórfico**: Mesma linguagem front e backend
- **Performance**: ~8,000 req/s - adequado para maioria dos casos

### 📊 **Comparação Prática**

```bash
# Performance comparison (requests/second)
Node.js: ~8,000 req/s   (baseline)
Go:     ~25,000 req/s   (3.1x faster)
```

### 🎯 **Cenários de Uso**

- **Go**: APIs corporativas, microservices, ferramentas DevOps
- **Node.js**: Protótipos rápidos, full-stack JS, real-time applications

> 💡 **Dica**: No load balancing, targets mais rápidos podem processar mais requests mesmo com peso igual, melhorando a performance geral do sistema.

## 🧹 Limpeza

```bash
docker-compose down -v
```
