# Projeto 7: Plugin Customizado em Lua

## 🎯 Objetivos
- Desenvolver plugin customizado em Lua
- Entender estrutura e lifecycle de plugins
- Implementar funcionalidades específicas de negócio
- Demonstrar extensibilidade do Kong

## 🏗️ Arquitetura
```
Cliente → Kong (Custom Plugin) → Mock API
```

## 📋 Conceitos Apresentados
- **Plugin Development Kit (PDK)**: APIs para desenvolvimento
- **Plugin Lifecycle**: access, auth, response, log phases
- **Schema Definition**: Configuração e validação
- **Custom Logic**: Regras específicas de negócio

## 🚀 Plugin Desenvolvido: Request Validator

Este plugin customizado implementa:
- Validação de headers obrigatórios
- Validação de tamanho de payload
- Rate limiting por user-id personalizado
- Logs estruturados com contexto

## 🚀 Como Executar

### 1. Construir imagem personalizada do Kong
```bash
docker build -t kong-custom .
```

### 2. Subir o ambiente
```bash
docker-compose up -d
```

### 3. Testar plugin customizado

#### 3.1 Request válido
```bash
curl -H "X-User-ID: user123" \
     -H "X-Client-Version: 1.0" \
     -X GET \
     http://localhost:8000/api/posts/1
```

#### 3.2 Request inválido (sem header obrigatório)
```bash
curl -X GET http://localhost:8000/api/posts/1
# Deve retornar 400 - Missing required header: X-User-ID
```

#### 3.3 Request inválido (payload muito grande)
```bash
curl -X POST http://localhost:8000/api/posts \
     -H "X-User-ID: user123" \
     -H "X-Client-Version: 1.0" \
     -H "Content-Type: application/json" \
     -d '{"title": "'$(openssl rand -base64 1000)'"}'
# Deve retornar 413 - Payload too large
```

#### 3.4 Testar rate limiting customizado
```bash
# Enviar múltiplas requests do mesmo usuário
for i in {1..6}; do
  curl -H "X-User-ID: user456" \
       -H "X-Client-Version: 1.0" \
       http://localhost:8000/api/posts/1
  sleep 0.1
done
# Após 5 requests, deve retornar 429
```

### 4. Ver logs do plugin
```bash
docker-compose logs kong | grep "request-validator"
```

### 5. Testar diferentes configurações
```bash
# Ver configuração atual do plugin
curl -s http://localhost:8001/routes/api-route/plugins | jq '.data[]'

# Modificar configuração (exemplo: max_payload_size)
curl -X PATCH http://localhost:8001/routes/api-route/plugins/<plugin-id> \
  -d "config.max_payload_size=2048"
```

## 📂 Estrutura do Plugin

```
kong/plugins/request-validator/
├── handler.lua          # Lógica principal do plugin  
├── schema.lua           # Configuração e validação
└── daos.lua            # Armazenamento (opcional)
```

### handler.lua
- Implementa fases do lifecycle
- Contém lógica de validação
- Usa Kong PDK para interagir com requests

### schema.lua  
- Define configurações aceitas
- Valida parâmetros de entrada
- Especifica valores default

## 📚 Pontos de Discussão

1. **Plugin Lifecycle**
   - **access**: Antes do upstream (auth, validations)
   - **header_filter**: Modifica response headers
   - **body_filter**: Modifica response body
   - **log**: Logging e cleanup

2. **Kong PDK (Plugin Development Kit)**
   - kong.request: Acesso ao request
   - kong.response: Manipular response  
   - kong.log: Logging estruturado
   - kong.ctx: Context sharing

3. **Performance**
   - Plugins executam a cada request
   - Cache quando possível
   - Evitar operações custosas

4. **Testing & Debugging**
   - Unit tests com busted
   - Integration tests com Pongo
   - Debug com logs estruturados

5. **Distribution**
   - LuaRocks packages
   - Custom Docker images
   - Plugin marketplaces

## 🧹 Limpeza
```bash
docker-compose down -v
docker rmi kong-custom
```
