# Projeto 3: Rate Limiting e Controle de Tráfego

## 🎯 Objetivos
- Implementar Rate Limiting por IP, Consumer e Header
- Configurar diferentes janelas de tempo
- Demonstrar headers de rate limiting
- Mostrar estratégias de controle de tráfego

## 🏗️ Arquitetura
```
Cliente → Kong (Rate Limit) → Mock API
```

## 📋 Conceitos Apresentados
- **Rate Limiting Plugin**: Controle por requests/minuto
- **Request Size Limiting**: Limite de tamanho de payload
- **Response Rate Limiting**: Limite de resposta upstream
- **Estratégias**: cluster, redis, local

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar rate limiting básico
```bash
# Execute múltiplas vezes rapidamente
for i in {1..10}; do
  curl -i http://localhost:8000/api/posts
  sleep 0.1
done
# Após 5 requests, deve retornar 429 Too Many Requests
```

### 3. Testar rate limiting por consumer
```bash
# Com consumer premium (limite maior)
for i in {1..15}; do
  curl -H "apikey: premium-key-456" -i http://localhost:8000/premium/posts
  sleep 0.1
done

# Com consumer básico (limite menor)
for i in {1..8}; do
  curl -H "apikey: basic-key-123" -i http://localhost:8000/premium/posts
  sleep 0.1
done
```

### 4. Testar rate limiting por header personalizado
```bash
# Diferentes clientes baseado em header
for i in {1..6}; do
  curl -H "X-Client-ID: mobile-app" -i http://localhost:8000/client/posts
  sleep 0.1
done

for i in {1..12}; do
  curl -H "X-Client-ID: web-app" -i http://localhost:8000/client/posts
  sleep 0.1
done
```

### 5. Monitorar headers de rate limiting
```bash
# Observe os headers retornados
curl -v http://localhost:8000/api/posts 2>&1 | grep -E "(X-RateLimit|429)"
```

### 6. Testar request size limiting
```bash
# Request muito grande (deve falhar)
curl -X POST http://localhost:8000/size-limit/posts \
  -H "Content-Type: application/json" \
  -d '{"data": "'$(openssl rand -base64 2048)'"}'
```

## 📚 Pontos de Discussão

1. **Estratégias de Rate Limiting**
   - Por IP: Protege contra ataques
   - Por Consumer: Planos diferenciados
   - Por Header: Diferentes tipos de cliente

2. **Janelas de Tempo**
   - second, minute, hour, day, month, year
   - Sliding window vs Fixed window

3. **Headers de Resposta**
   - X-RateLimit-Limit: Limite configurado
   - X-RateLimit-Remaining: Requests restantes
   - X-RateLimit-Reset: Quando o limite reseta

4. **Estratégias de Armazenamento**
   - local: Performance, mas não distribuído
   - cluster: Distribuído entre nós Kong
   - redis: External store, mais preciso

## 🧹 Limpeza
```bash
docker-compose down -v
```
