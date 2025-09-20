# Custom Plugin Lua - Request Validator

Este projeto demonstra como criar um plugin customizado em Lua para Kong Gateway que implementa validações avançadas de requests.

## Funcionalidades

- **Validação de Headers Obrigatórios**: Verifica se headers específicos estão presentes
- **Rate Limiting por User-ID**: Controla taxa de requests por usuário usando header X-User-ID
- **Validação de Tamanho de Payload**: Limita tamanho de requests POST/PUT/PATCH
- **Logging Detalhado**: Registra informações de performance e debug

## Como Executar

1. **Subir os serviços:**
   ```bash
   docker compose up -d
   ```

2. **Verificar saúde dos serviços:**
   ```bash
   docker compose ps
   curl -s http://localhost:8001/status | jq
   ```

3. **Testar request válido:**
   ```bash
   curl -X GET http://localhost:8000/api/posts \
     -H "X-User-ID: user123" \
     -H "X-Client-Version: 1.0.0"
   ```

4. **Testar rate limiting (fazer mais de 5 requests em 1 minuto):**
   ```bash
   for i in {1..7}; do
     curl -X GET http://localhost:8000/api/posts \
       -H "X-User-ID: user123" \
       -H "X-Client-Version: 1.0.0" \
       -w "Request $i: %{http_code}\n"
     sleep 1
   done
   ```

5. **Testar header obrigatório ausente:**
   ```bash
   curl -X GET http://localhost:8000/api/posts \
     -H "X-Client-Version: 1.0.0"
   ```

6. **Testar payload muito grande:**
   ```bash
   curl -X POST http://localhost:8000/api/posts \
     -H "X-User-ID: user123" \
     -H "X-Client-Version: 1.0.0" \
     -H "Content-Type: application/json" \
     -d "$(printf '{"data":"%s"}' "$(head -c 2000 /dev/zero | tr '\0' 'a')")"
   ```

## Configuração do Plugin

O plugin é configurado no arquivo `kong.yml`:

```yaml
plugins:
  - name: request-validator
    route: api-route
    config:
      required_headers:
        - "X-User-ID"
        - "X-Client-Version"
      max_payload_size: 1024  # 1KB
      rate_limit_per_minute: 5
      enable_payload_validation: true
      enable_rate_limiting: true
```

## Estrutura dos Arquivos

- `kong/plugins/request-validator/handler.lua`: Lógica principal do plugin
- `kong/plugins/request-validator/schema.lua`: Definição da configuração
- `Dockerfile`: Build customizado do Kong com o plugin
- `docker-compose.yml`: Orquestração dos serviços
- `kong.yml`: Configuração declarativa do Kong

## Logs

Para acompanhar os logs do plugin:

```bash
docker compose logs -f kong
```

## Limpeza

Para parar e remover todos os recursos:

```bash
docker compose down -v
```