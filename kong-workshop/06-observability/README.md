# Projeto 6: Observabilidade - Logging e Monitoramento

## 🎯 Objetivos
- Configurar HTTP Log plugin para enviar logs
- Implementar Prometheus metrics
- Configurar TCP/UDP/File logging
- Demonstrar observabilidade completa

## 🏗️ Arquitetura
```
Cliente → Kong → Mock API
              ↓
         Log Collector
```

## 📋 Conceitos Apresentados
- **HTTP Log Plugin**: Envio de logs via HTTP
- **Prometheus Plugin**: Métricas de performance
- **File Log Plugin**: Logs em arquivos
- **TCP/UDP Log**: Logs para sistemas externos

## 🚀 Como Executar

### 1. Subir o ambiente completo
```bash
docker-compose up -d
```

### 2. Gerar tráfego para logs
```bash
# Gerar requests de teste
for i in {1..20}; do
  curl -s http://localhost:8000/api/posts/$((i%3+1)) > /dev/null
  curl -s http://localhost:8000/api/users/$((i%2+1)) > /dev/null
  sleep 0.2
done
```

### 3. Ver métricas do Prometheus
```bash
# Acessar métricas do Kong
curl http://localhost:8000/metrics

# Ver métricas específicas
curl -s http://localhost:8000/metrics | grep kong_http_requests_total
```

### 4. Verificar logs HTTP
```bash
# Ver logs do log collector
docker-compose logs log-collector
```

### 5. Acessar Grafana (opcional)
- URL: http://localhost:3000
- User: admin / Password: admin
- Importar dashboard do Kong

## 📚 Pontos de Discussão

1. **Tipos de Observabilidade**
   - Metrics: Prometheus, StatsD
   - Logs: Structured logging
   - Traces: Jaeger, Zipkin

2. **Performance Impact**
   - Logging plugins podem afetar latência
   - Buffering e batching
   - Sampling strategies

## 🧹 Limpeza
```bash
docker-compose down -v
```
