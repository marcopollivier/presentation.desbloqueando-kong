# Projeto 1: Kong Básico - Proxy Simples

## 🎯 Objetivos
- Entender conceitos fundamentais: Services, Routes, Upstreams
- Configurar Kong como proxy reverso
- Usar configuração declarativa

## 🏗️ Arquitetura
```
Cliente → Kong Gateway → Mock API
```

## 📋 Conceitos Apresentados
- **Service**: Define um serviço upstream (backend)
- **Route**: Define como requests chegam ao Service
- **Configuração Declarativa**: kong.yml vs Admin API

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar o proxy
```bash
# Teste básico - deve retornar dados do JSONPlaceholder
curl -i http://localhost:8000/api/posts

# Teste com parâmetro
curl -i http://localhost:8000/api/posts/1

# Verificar status do Kong
curl -i http://localhost:8001/status
```

### 3. Explorar configurações
```bash
# Listar services
curl -s http://localhost:8001/services | jq

# Listar routes
curl -s http://localhost:8001/routes | jq

# Ver métricas básicas
curl -s http://localhost:8001/status | jq
```

## 📚 Pontos de Discussão para Palestra

1. **Por que usar um API Gateway?**
   - Ponto único de entrada
   - Políticas centralizadas
   - Observabilidade

2. **Kong vs outras soluções**
   - Performance (Nginx + OpenResty)
   - Extensibilidade (Lua plugins)
   - Comunidade e ecosistema

3. **Configuração Declarativa vs Admin API**
   - Prós/contras de cada abordagem
   - GitOps com kong.yml

## 🧹 Limpeza
```bash
docker-compose down -v
```
