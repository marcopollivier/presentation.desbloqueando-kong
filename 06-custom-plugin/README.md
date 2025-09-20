# Projeto 06: Plugin Customizado em Lua

## 🎯 Objetivos

- Desenvolver plugin customizado em Lua
- Entender estrutura e lifecycle de plugins
- Implementar funcionalidades específicas de negócio
- Demonstrar extensibilidade do Kong

## 🏗️ Arquitetura

```text
Cliente → Kong (Custom Plugin) → Mock API
```

## 📋 Conceitos Apresentados

- **Plugin Development Kit (PDK)**: APIs para desenvolvimento
- **Plugin Lifecycle**: access, auth, response, log phases
- **Schema Definition**: Configuração e validação
- **Custom Logic**: Regras específicas de negócio

## 🚀 Plugin Desenvolvido: Request Validator

Este plugin customizado implementa:

- **Validação de Headers Obrigatórios**: Verifica se headers específicos estão presentes
- **Rate Limiting por User-ID**: Controla taxa de requests por usuário usando header X-User-ID
- **Validação de Tamanho de Payload**: Limita tamanho de requests POST/PUT/PATCH
- **Logging Detalhado**: Registra informações de performance e debug

## 🚀 Como Executar

### 1. Subir os serviços
```bash
docker compose up -d
```

### 2. Verificar saúde dos serviços
```bash
docker compose ps
curl -s http://localhost:8001/status | jq
```

### 3. Testar plugin customizado

#### 3.1 Request válido
```bash
curl -X GET http://localhost:8000/api/posts \
  -H "X-User-ID: user123" \
  -H "X-Client-Version: 1.0.0"
```

#### 3.2 Request inválido (sem header obrigatório)
```bash
curl -X GET http://localhost:8000/api/posts \
  -H "X-Client-Version: 1.0.0"
# Deve retornar 400 - Missing required header: X-User-ID
```

#### 3.3 Request inválido (payload muito grande)
```bash
curl -X POST http://localhost:8000/api/posts \
  -H "X-User-ID: user123" \
  -H "X-Client-Version: 1.0.0" \
  -H "Content-Type: application/json" \
  -d "$(printf '{"data":"%s"}' "$(head -c 2000 /dev/zero | tr '\0' 'a')")"
# Deve retornar 413 - Payload too large
```

#### 3.4 Testar rate limiting customizado
```bash
# Enviar múltiplas requests do mesmo usuário (mais de 5 em 1 minuto)
for i in {1..7}; do
  curl -X GET http://localhost:8000/api/posts \
    -H "X-User-ID: user456" \
    -H "X-Client-Version: 1.0.0" \
    -w "Request $i: %{http_code}\n"
  sleep 1
done
# Após 5 requests, deve retornar 429
```

### 4. Ver logs do plugin
```bash
docker compose logs -f kong | grep "request-validator"
```

### 5. Testar diferentes configurações
```bash
# Ver configuração atual do plugin
curl -s http://localhost:8001/routes/api-route/plugins | jq '.data[]'

# Modificar configuração (exemplo: max_payload_size)
curl -X PATCH http://localhost:8001/routes/api-route/plugins/<plugin-id> \
  -d "config.max_payload_size=2048"
```

## ⚙️ Configuração do Plugin

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

## 🧹 Limpeza

```bash
docker compose down -v
```

## 📂 Estrutura dos Arquivos

```text
kong/plugins/request-validator/
├── handler.lua          # Lógica principal do plugin  
├── schema.lua           # Configuração e validação
└── daos.lua            # Armazenamento (opcional)
```

- `kong/plugins/request-validator/handler.lua`: Implementa fases do lifecycle e lógica de validação
- `kong/plugins/request-validator/schema.lua`: Define configurações aceitas e validação de parâmetros
- `Dockerfile`: Build customizado do Kong com o plugin
- `docker-compose.yml`: Orquestração dos serviços
- `kong.yml`: Configuração declarativa do Kong

## 📚 Conceitos Importantes

### Plugin Lifecycle

- **access**: Antes do upstream (auth, validations)
- **header_filter**: Modifica response headers
- **body_filter**: Modifica response body
- **log**: Logging e cleanup

### Kong PDK (Plugin Development Kit)

- `kong.request`: Acesso ao request
- `kong.response`: Manipular response  
- `kong.log`: Logging estruturado
- `kong.ctx`: Context sharing

### Performance e Boas Práticas

- Plugins executam a cada request
- Cache quando possível
- Evitar operações custosas
- Debug com logs estruturados
