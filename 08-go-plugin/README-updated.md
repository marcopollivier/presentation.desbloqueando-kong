# Go Plugin com Bridge Lua

Este projeto demonstra como integrar validação Go com Kong usando uma arquitetura híbrida:
- Plugin Lua (`go-validator-bridge`) que atua como ponte
- Serviço Go que implementa a lógica de validação
- Comunicação via HTTP entre os componentes

## Arquitetura

```
Request → Kong → Plugin Lua → Serviço Go → Response
```

O plugin Lua intercepta requests e envia para o serviço Go para validação avançada.

## Funcionalidades

- **Validação de Métodos HTTP**: Controla quais métodos são permitidos
- **Headers Obrigatórios**: Verifica presença de headers específicos
- **Rate Limiting Distribuído**: Usa Redis para controle de taxa entre instâncias
- **Debug Headers**: Adiciona informações de debug nas respostas
- **Fallback em Caso de Erro**: Configura comportamento quando serviço Go está indisponível

## Como Executar

1. **Subir todos os serviços:**

   ```bash
   docker compose up -d
   ```

2. **Verificar saúde dos serviços:**

   ```bash
   # Kong Admin API
   curl http://localhost:8001/status
   
   # Serviço Go
   curl http://localhost:8002/health
   
   # Redis
   docker compose exec redis redis-cli ping
   ```

3. **Testar request válido:**

   ```bash
   curl -X GET http://localhost:8000/api/get \
     -H "Content-Type: application/json" \
     -H "X-Client-ID: client-123"
   ```

4. **Testar header obrigatório ausente:**

   ```bash
   curl -X GET http://localhost:8000/api/get
   # Deve retornar erro 400
   ```

5. **Testar rate limiting:**

   ```bash
   # Execute várias vezes rapidamente
   for i in {1..15}; do
     curl -X GET http://localhost:8000/api/get \
       -H "Content-Type: application/json" \
       -H "X-Client-ID: rate-test" \
       -w "Request $i: %{http_code}\n"
   done
   ```

6. **Usar arquivo de testes:**

   ```bash
   # Executar testes simples
   chmod +x simple-test.sh
   ./simple-test.sh
   ```

## Configuração

### Plugin Bridge (kong.yml)

```yaml
plugins:
  - name: go-validator-bridge
    service: test-service
    config:
      go_service_host: "go-validator"
      go_service_port: 8002
      timeout: 5000
      fail_on_error: true
      max_requests_per_minute: 10
      required_headers:
        - "Content-Type"
        - "X-Client-ID"
      allowed_methods:
        - "GET"
        - "POST"
        - "PUT"
        - "DELETE"
```

### Serviço Go

O serviço Go expõe os seguintes endpoints:

- `POST /validate`: Endpoint principal de validação
- `GET /health`: Health check
- `GET /status`: Status do serviço

## Estrutura dos Arquivos

### Plugin Lua Bridge
- `kong/plugins/go-validator-bridge/handler.lua`: Lógica de comunicação HTTP
- `kong/plugins/go-validator-bridge/schema.lua`: Schema de configuração

### Serviço Go
- `go-plugin/main.go`: Servidor HTTP principal
- `go-plugin/plugin/config.go`: Estruturas de dados e configuração
- `go-plugin/plugin/handler.go`: Lógica de validação
- `go-plugin/Dockerfile`: Build do serviço Go

### Infraestrutura
- `docker-compose.yml`: Orquestração completa (Kong, Go, Redis, PostgreSQL)
- `kong.yml`: Configuração declarativa do Kong
- `simple-test.sh`: Script de testes básicos

## Exemplo de Request/Response

### Request Válido

```bash
curl -X GET http://localhost:8000/api/get \
  -H "Content-Type: application/json" \
  -H "X-Client-ID: example-client"
```

### Response Headers Adicionados

```
X-Validated-By: go-validator-bridge
X-Bridge-Version: 1.0.0
X-Go-Validator-Validated-Method: GET
X-Go-Validator-Client-IP: 172.18.0.1
```

## Monitoramento

### Logs do Kong

```bash
docker compose logs -f kong
```

### Logs do Serviço Go

```bash
docker compose logs -f go-validator
```

### Monitorar Redis

```bash
docker compose exec redis redis-cli monitor
```

## Troubleshooting

### Kong não consegue conectar no serviço Go

```bash
# Verificar se o serviço Go está saudável
curl http://localhost:8002/health

# Verificar logs
docker compose logs go-validator
```

### Rate limiting não funciona

```bash
# Verificar conexão com Redis
docker compose exec redis redis-cli ping

# Verificar chaves do rate limiting
docker compose exec redis redis-cli keys "rate_limit:*"
```

### Plugin não carrega

```bash
# Verificar sintaxe Lua
docker compose logs kong | grep "plugin"

# Verificar se plugin está registrado
curl http://localhost:8001/plugins
```

## Vantagens desta Arquitetura

1. **Compatibilidade**: Funciona com versões recentes do Kong
2. **Flexibilidade**: Fácil de modificar a lógica de validação no Go
3. **Performance**: Redis para cache distribuído
4. **Observabilidade**: Logs separados para cada componente
5. **Escalabilidade**: Serviço Go pode ser escalado independentemente

## Limpeza

```bash
docker compose down -v
```