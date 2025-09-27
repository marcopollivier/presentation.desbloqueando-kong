# Projeto 4: Rate Limiting Básico

## 🎯 Objetivos
- Implementar Rate Limiting básico por IP
- Configurar janelas de tempo simples
- Demonstrar headers de rate limiting
- Proteger APIs contra abuso

## 🏗️ Arquitetura
```
Cliente → Kong (Rate Limit) → JSONPlaceholder API
```

## 📋 Conceitos Apresentados
- **Rate Limiting Plugin**: Controle por requests/minuto
- **Política Local**: Armazenamento em memória
- **Headers informativos**: X-RateLimit-*

## 🚀 Como Executar

### 1. Subir o ambiente
```bash
docker-compose up -d
```

### 2. Testar funcionamento normal
```bash
# Request simples para verificar que está funcionando
curl -i http://localhost:8000/api/posts
```

### 3. Testar rate limiting
```bash
# Execute múltiplas vezes rapidamente para atingir o limite
for i in {1..10}; do
  echo "Request $i:"
  curl -i http://localhost:8000/api/posts | head -1
  sleep 0.5
done
# Após 5 requests no minuto, deve retornar 429 Too Many Requests
```

### 4. Observar headers de rate limiting
```bash
# Veja os headers informativos
curl -v http://localhost:8000/api/posts 2>&1 | grep -E "X-RateLimit"
```

### 5. Aguarde 1 minuto e teste novamente
```bash
# Após 1 minuto, o limite deve ser resetado
sleep 60
curl -i http://localhost:8000/api/posts
```

## 📚 Pontos de Discussão

1. **Rate Limiting por IP**
   - Protege contra ataques de força bruta
   - Identifica automaticamente pelo IP do cliente
   - Simples de configurar e entender

2. **Configuração de Janelas**
   - `minute: 5` = 5 requests por minuto
   - `hour: 100` = 100 requests por hora
   - Controle duplo de limite

3. **Headers de Resposta**
   - `X-RateLimit-Limit-Minute`: Limite por minuto
   - `X-RateLimit-Remaining-Minute`: Requests restantes
   - `X-RateLimit-Limit-Hour`: Limite por hora
   - `X-RateLimit-Remaining-Hour`: Requests restantes na hora

4. **Política Local**
   - `policy: local`: Armazena contadores em memória
   - Mais rápido, mas não distribuído
   - Ideal para single-node ou testes

## 🧹 Limpeza
```bash
docker-compose down -v
```
